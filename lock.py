
import os
import re

# 日志文件路径
log_file_path = '/Users/hans/Documents/tmp/androidPull.txt'  # 替换为你的日志文件路径
# Git refs 目录路径
git_refs_dir = os.path.expanduser('~/android/.git/refs/remotes/origin/')

# 定义一个正则表达式来匹配 branch 名
branch_pattern = re.compile(r"error: cannot lock ref 'refs/remotes/origin/([^/]+)/(.+)'")

# 存储提取的 branch 名的数组
branch_names = []

# 从日志文件中读取并提取 branch 名
with open(log_file_path, 'r') as log_file:
    for line in log_file:
        match = branch_pattern.search(line)
        if match:
            branch = match.group(2)  # 获取 branch 名，不包括前面的 feature/
            branch_names.append(branch)
            
# 输出提取到的 branch 名
print("提取到的 branch 名：", branch_names)

# 遍历 refs 目录及其子文件夹
for root, dirs, files in os.walk(git_refs_dir):
    for file in files:
        # 仅保留branch名部分，去掉路径中的其他部分
        for branch in branch_names:
            if file == branch:  # 检查当前文件名是否与提取的 branch 名相符
                file_path = os.path.join(root, file)  # 获取文件的完整路径
                if os.path.exists(file_path):
                    os.remove(file_path)
                    print(f"已删除: {file_path}")
                else:
                    print(f"文件不存在: {file_path}")
        
        
        