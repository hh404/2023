#!/usr/bin/env bash
set -euo pipefail

JSON_FILE="${1:-packages.json}"
MIRROR_ROOT="${2:-$HOME/mirror}"

STATE_FILE="${3:-mirror_state.json}"   # 记录每个 URL 的成功/失败与本地路径
FAILED_FILE="${4:-failed.txt}"         # 失败列表（纯文本，便于 grep/重跑）

mkdir -p "$MIRROR_ROOT"

python3 - "$JSON_FILE" "$MIRROR_ROOT" "$STATE_FILE" "$FAILED_FILE" <<'PY'
import json, os, re, subprocess, sys, urllib.parse, time

json_file = os.path.expanduser(sys.argv[1])
mirror_root = os.path.expanduser(sys.argv[2])
state_file = os.path.expanduser(sys.argv[3])
failed_file = os.path.expanduser(sys.argv[4])

def run(cmd, cwd=None, allow_fail=False):
    print(f"$ {' '.join(cmd)}")
    p = subprocess.run(cmd, cwd=cwd)
    if not allow_fail and p.returncode != 0:
        raise subprocess.CalledProcessError(p.returncode, cmd)
    return p.returncode

def capture(cmd):
    return subprocess.check_output(cmd).decode("utf-8", errors="replace")

def normalize_url(u: str) -> str:
    return u.strip()

def parse_repo(u: str):
    """
    Return (host, org, repo, https_with_git, https_without_git, original_url)
    Supports:
      - https://host/org/repo(.git)
      - git@host:org/repo(.git)
    For SSH, we still derive equivalent https URLs for insteadOf matching.
    """
    u0 = normalize_url(u)

    # SSH: git@github.com:org/repo.git
    m = re.match(r'^[^@]+@([^:]+):([^/]+)/(.+?)(?:\.git)?$', u0)
    if m:
        host, org, repo = m.group(1), m.group(2), m.group(3)
        https_without = f"https://{host}/{org}/{repo}"
        https_with = https_without + ".git"
        return host, org, repo, https_with, https_without, u0

    # HTTPS: https://github.com/org/repo(.git)
    if u0.startswith("http://") or u0.startswith("https://"):
        p = urllib.parse.urlparse(u0)
        host = p.netloc
        parts = [x for x in p.path.split("/") if x]
        if len(parts) >= 2:
            org = parts[0]
            repo = parts[1]
            if repo.endswith(".git"):
                repo = repo[:-4]
            https_without = f"https://{host}/{org}/{repo}"
            https_with = https_without + ".git"
            return host, org, repo, https_with, https_without, u0

    return None

def safe_path_component(s: str) -> str:
    return re.sub(r'[^A-Za-z0-9._-]+', '_', s)

def is_bare_git_repo(path: str) -> bool:
    # mirror -- bare repo: has HEAD + objects + refs (一般都有)
    return os.path.isdir(path) and os.path.isfile(os.path.join(path, "HEAD")) and os.path.isdir(os.path.join(path, "objects"))

def load_state():
    if os.path.isfile(state_file):
        try:
            with open(state_file, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            return {}
    return {}

def save_state(state):
    tmp = state_file + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(state, f, ensure_ascii=False, indent=2)
    os.replace(tmp, state_file)

def append_failed(line: str):
    with open(failed_file, "a", encoding="utf-8") as f:
        f.write(line.rstrip("\n") + "\n")

def git_config_has_insteadOf(file_url_prefix: str, instead_of: str) -> bool:
    key = f'url.{file_url_prefix}.insteadOf'
    rc = run(["git", "config", "--global", "--get-all", key], allow_fail=True)
    if rc != 0:
        return False
    vals = capture(["git", "config", "--global", "--get-all", key]).splitlines()
    return any(v.strip() == instead_of for v in vals)

def git_config_add_insteadOf(file_url_prefix: str, instead_of: str):
    if git_config_has_insteadOf(file_url_prefix, instead_of):
        print(f"git config exists, skip: {file_url_prefix} <= {instead_of}")
        return
    run(["git", "config", "--global", "--add", f'url.{file_url_prefix}.insteadOf', instead_of])
    print(f"git config added: {file_url_prefix} <= {instead_of}")

with open(json_file, "r", encoding="utf-8") as f:
    urls = json.load(f)

if not isinstance(urls, list):
    raise SystemExit("JSON must be an array of repo url strings")

state = load_state()
# 清空 failed 文件（每次跑重新生成一份本轮失败）
open(failed_file, "w", encoding="utf-8").close()

total = len(urls)
for idx, u in enumerate(urls, 1):
    if not isinstance(u, str) or not u.strip():
        continue

    u = normalize_url(u)
    info = parse_repo(u)
    if info:
        host, org, repo, https_with, https_without, original = info
        dst_dir = os.path.join(mirror_root, host, org, repo + ".git")
        file_prefix = "file://" + os.path.join(mirror_root, host, org, repo + ".git")
    else:
        dst_dir = os.path.join(mirror_root, "_unknown", safe_path_component(u) + ".git")
        file_prefix = "file://" + dst_dir

    os.makedirs(os.path.dirname(dst_dir), exist_ok=True)

    print(f"\n[{idx}/{total}] {u}")
    print(f"Mirror => {dst_dir}")

    try:
        if is_bare_git_repo(dst_dir):
            # 已存在：不重复 clone；做一次 update 保持最新（如需完全跳过 update，可自行改此处）
            run(["git", "-C", dst_dir, "remote", "update", "--prune"])
            status = "success"
        else:
            # 目录存在但不完整：删掉重来，避免坏状态
            if os.path.exists(dst_dir):
                import shutil
                shutil.rmtree(dst_dir)
            run(["git", "clone", "--mirror", u, dst_dir])
            status = "success"

        # mirror 成功后，写入 git config（去重）
        if info:
            # 同时覆盖 .git / 无 .git 两种写法
            git_config_add_insteadOf(file_prefix, https_with)
            git_config_add_insteadOf(file_prefix, https_without)

            # 兼容 SSH 形式（常见）
            ssh1 = f"git@{host}:{org}/{repo}.git"
            ssh2 = f"git@{host}:{org}/{repo}"
            git_config_add_insteadOf(file_prefix, ssh1)
            git_config_add_insteadOf(file_prefix, ssh2)

        state[u] = {
            "status": status,
            "dst": dst_dir,
            "updatedAt": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
        }
        save_state(state)

    except Exception as e:
        print(f"FAILED: {u}\n  reason: {e}")
        append_failed(u)
        state[u] = {
            "status": "failed",
            "dst": dst_dir,
            "updatedAt": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
            "error": str(e),
        }
        save_state(state)
        # 不终止整批：继续下一个
        continue

print("\nDone.")
print(f"State: {state_file}")
print(f"Failed list: {failed_file}")
PY
