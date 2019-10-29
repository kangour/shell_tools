current_branch=`git rev-parse --abbrev-ref HEAD`
result=`git stash`
echo $result

# 暂存未提交的变更
stash_status=false
if [[ $result =~ 'Saved' ]]
then
    echo '变更未提交，自动暂存'
    stash_status=true
fi

# 切到 master 并清理无用分支
git checkout master
git pull
git remote prune origin
git branch --merged | egrep -v "(^\*|master)" | xargs git branch -d

# 还原当前分支
result=`git branch`
if [[ $result =~ $current_branch ]]
then
    _branch=`git rev-parse --abbrev-ref HEAD`
    if [[ $current_branch == $_branch ]]
    then
        echo '分支正常'
    else
        echo '切回分支'
        git checkout $current_branch
    fi
else
    echo '还原分支'
    git checkout -b $current_branch
fi

# 还原暂存区
if [[ $stash_status == true ]]
then
    echo '还原暂存'
    git stash pop
fi
echo '操作完成!'
