# Usage: ./xxx.sh [target_merge_branch]
# 功能描述：
# 将当前分支推送到远端，并通过浏览器打开代码合并的地址
# 参数说明：
# target_merge_branch 需要合并到什么分支？可以传入任何已经存在的分支，例如 master，beta，alpha，debug

target_merge_branch="master"  # 默认合并到 master 分支

# 读取分支名称
if [ -n "$1" ]; then
    target_merge_branch=$1
else
    echo "未指定合并目标分支，将默认合并到 ${target_merge_branch} 分支"
fi


current_branch=`git rev-parse --abbrev-ref HEAD`
git fetch
git push --set-upstream origin $current_branch
# git checkout master


# 获取git远程仓库的SSH URL
ssh_url=$(git remote -v | grep fetch | head -n 1 | awk '{print $2}')

# 检查是否获取到了SSH URL
if [ -z "$ssh_url" ]; then
    echo "没有找到SSH URL，请确保你在Git仓库的目录下运行此脚本。"
    exit 1
fi

echo "sshurl: $ssh_url"

# 提取仓库的用户名和仓库名
repo_name=$(echo $ssh_url | awk -F':' '{print $2}' | awk -F'.' '{print $1}')
user_name=$(echo $ssh_url | awk -F':' '{print $1}' | sed 's/git@//')

echo "repo name: $repo_name"
echo "user name: $user_name"

# 替换SSH URL为HTTP URL
http_url="https://${user_name}/${repo_name}"

echo "http_url: $http_url"

# 拼接创建合并请求的URL
merge_request_url="${http_url}/merge_requests/new?merge_request%5Bsource_branch%5D=${current_branch}&merge_request%5Btarget_branch%5D=${target_merge_branch}"
echo "merge request:"
echo ""
echo ""
echo "$merge_request_url"
echo ""
echo ""

# 浏览器进入转换后的URL
open $merge_request_url

