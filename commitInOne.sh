#!/bin/bash

# 添加所有更改
git add .

# 生成随机的 commit 信息
commit_message="Commit: $(date '+%Y-%m-%d %H:%M:%S')"

# 提交更改，使用随机的 commit 信息
git commit -m "$commit_message"

# 推送到远程仓库
git push origin main

echo "更改已提交并推送到远程仓库，使用随机的 commit 信息。"

