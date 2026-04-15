#!/bin/bash

# =============================================================================
# PR Conflict Resolver
#
# 解决 PR 冲突而不污染当前 branch
# 
# 原理：
#   1. 试 merge target branch，拿到冲突文件列表
#   2. 立刻 reset 回去（不保留 merge）
#   3. 用 git merge-file 对每个冲突文件精准制造冲突标记
#   4. 开发者在 VS Code 里手动解决
#   5. 一次性 commit push
#
# 用法：
#   ./resolve-pr-conflict.sh <target_branch>
#
# 示例：
#   ./resolve-pr-conflict.sh origin/feature/AB#12345-payment
#   ./resolve-pr-conflict.sh origin/develop
#
# =============================================================================

set -e

# ── 参数检查 ──────────────────────────────────────────────
TARGET="${1:?Usage: ./resolve-pr-conflict.sh <target_branch>}"
CURRENT=$(git branch --show-current)

if [ -z "$CURRENT" ]; then
  echo "❌ Not on a branch. Please checkout your branch first."
  exit 1
fi

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║         PR Conflict Resolver                    ║"
echo "╠══════════════════════════════════════════════════╣"
echo "║  Source (yours):  $CURRENT"
echo "║  Target (merge):  $TARGET"
echo "╚══════════════════════════════════════════════════╝"
echo ""

# ── Step 1: 检查工作区是否干净 ─────────────────────────────
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "❌ Working directory is not clean. Please commit or stash first."
  exit 1
fi

# ── Step 2: Fetch 最新代码 ─────────────────────────────────
echo "📡 Fetching latest..."
git fetch origin

# ── Step 3: 试 merge，捕获冲突文件 ─────────────────────────
echo "🔍 Trial merge to detect conflicts..."
MERGE_OUTPUT=$(git merge --no-commit --no-ff "$TARGET" 2>&1 || true)

# 检查是否有冲突
CONFLICT_FILES=$(git diff --name-only --diff-filter=U 2>/dev/null)

if [ -z "$CONFLICT_FILES" ]; then
  echo "✅ No conflicts found! The PR should be mergeable."
  git merge --abort 2>/dev/null || true
  exit 0
fi

# 保存冲突文件列表
echo "$CONFLICT_FILES" > /tmp/conflict_files.txt
CONFLICT_COUNT=$(echo "$CONFLICT_FILES" | wc -l | tr -d ' ')

echo ""
echo "⚠️  Found $CONFLICT_COUNT conflict file(s):"
echo "$CONFLICT_FILES" | while read f; do echo "   • $f"; done
echo ""

# ── Step 4: Reset 回去，撤销 merge ─────────────────────────
echo "⏪ Resetting merge (cleaning up)..."
git merge --abort

echo "✅ Branch is clean again."
echo ""

# ── Step 5: 找到 merge base ────────────────────────────────
BASE=$(git merge-base "$CURRENT" "$TARGET")
echo "📌 Merge base: ${BASE:0:8}"
echo ""

# ── Step 6: 对每个冲突文件运行 git merge-file ──────────────
echo "🔧 Generating conflict markers..."
echo ""

FAILED_FILES=""
SUCCESS_COUNT=0

while IFS= read -r filepath; do
  echo "   Processing: $filepath"
  
  # 准备三个版本的临时文件
  TMPDIR=$(mktemp -d)
  BASE_FILE="$TMPDIR/base"
  THEIRS_FILE="$TMPDIR/theirs"
  
  # 获取 base 版本
  if ! git show "$BASE:$filepath" > "$BASE_FILE" 2>/dev/null; then
    echo "     ⚠️  File not in base (new file) — skipping merge-file, needs manual check"
    FAILED_FILES="$FAILED_FILES\n   • $filepath (new file, no common base)"
    rm -rf "$TMPDIR"
    continue
  fi
  
  # 获取 target (theirs) 版本
  if ! git show "$TARGET:$filepath" > "$THEIRS_FILE" 2>/dev/null; then
    echo "     ⚠️  File not in target — skipping"
    FAILED_FILES="$FAILED_FILES\n   • $filepath (not in target)"
    rm -rf "$TMPDIR"
    continue
  fi
  
  # 运行 merge-file（返回值 > 0 表示有冲突，这是正常的）
  git merge-file "$filepath" "$BASE_FILE" "$THEIRS_FILE" || true
  
  echo "     ✅ Conflict markers inserted"
  SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
  
  # 清理临时文件
  rm -rf "$TMPDIR"
  
done < /tmp/conflict_files.txt

echo ""
echo "══════════════════════════════════════════════════"
echo ""
echo "📊 Result: $SUCCESS_COUNT file(s) with conflict markers"

if [ -n "$FAILED_FILES" ]; then
  echo ""
  echo "⚠️  Skipped files (need manual check):"
  echo -e "$FAILED_FILES"
fi

echo ""
echo "📝 Next steps:"
echo ""
echo "   1. Open VS Code — conflict files will show merge markers"
echo "      code $(echo "$CONFLICT_FILES" | head -1)"
echo ""
echo "   2. Resolve each file (<<<<<<< ======= >>>>>>>)"
echo ""
echo "   3. When done, commit and push:"
echo "      git add ."
echo '      git commit -m "fix: resolve PR conflicts with '"$TARGET"'"'
echo "      git push origin $CURRENT"
echo ""
echo "   4. PR will auto-update — conflicts gone ✅"
echo ""

# 清理
rm -f /tmp/conflict_files.txt
