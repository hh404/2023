#!/usr/bin/env python3
"""
DBeaver 查询结果（pipe 格式）→ Markdown 表格

用法：
  pbpaste | python3 dbeaver_to_markdown.py          # macOS 直接从剪贴板
  python3 dbeaver_to_markdown.py < input.txt        # 从文件读取
  python3 dbeaver_to_markdown.py < input.txt -o out.md  # 输出到文件
"""

import sys
import argparse


def parse_dbeaver(text: str) -> list[list[str]]:
    rows = []
    for line in text.splitlines():
        line = line.strip()
        if not line:
            continue
        # 跳过分隔线（如 ----------+---------+--------）
        if all(c in '-+' for c in line.replace(' ', '')):
            continue
        # 解析 | cell | cell | 格式
        cells = [c.strip() for c in line.strip('|').split('|')]
        rows.append(cells)
    return rows


def to_markdown(rows: list[list[str]]) -> str:
    if not rows:
        return ""

    col_count = max(len(r) for r in rows)
    rows = [(r + [''] * col_count)[:col_count] for r in rows]

    def width(s):
        return sum(2 if ord(c) > 127 else 1 for c in s)

    col_widths = [max(width(r[i]) for r in rows) for i in range(col_count)]
    col_widths = [max(w, 3) for w in col_widths]

    def pad(s, w):
        return s + ' ' * (w - width(s))

    def row_line(r):
        return '| ' + ' | '.join(pad(r[i], col_widths[i]) for i in range(col_count)) + ' |'

    sep = '| ' + ' | '.join('-' * w for w in col_widths) + ' |'

    lines = [row_line(rows[0]), sep] + [row_line(r) for r in rows[1:]]
    return '\n'.join(lines)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-o', '--output', help='输出文件路径')
    args = parser.parse_args()

    text = sys.stdin.read()
    rows = parse_dbeaver(text)
    result = to_markdown(rows)

    if args.output:
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write(result + '\n')
        print(f"✅ 已写入 {args.output}")
    else:
        print(result)


if __name__ == '__main__':
    main()