current_branch=`git rev-parse --abbrev-ref HEAD`
echo '暂存检查'
result=`git stash`
echo ''
echo $result
echo ''

# 暂存未提交的变更

stash_status=false
if [[ $result =~ 'Saved' ]]
then
    echo '变更未提交，自动暂存'
    stash_status=true
else
    echo '无变更，无需暂存'
fi

echo ''
echo '切到 master 并清理无用分支'
echo ''

git checkout master
echo ''
git pull
echo ''
git remote prune origin
echo ''
git branch --merged | egrep -v "(^\*|master)" | xargs git branch -d
echo ''

# 还原暂存区

if [[ $stash_status == true ]]
then

    # 还原当前分支
    result=`git branch`
    if [[ $result =~ $current_branch ]]
    then
        _branch=`git rev-parse --abbrev-ref HEAD`
        if [[ $current_branch == $_branch ]]
        then
            echo '分支未发生变化'
        else
            echo '切回旧分支'
            git checkout $current_branch
        fi
    else
        echo '创建还原分支'
        git checkout -b $current_branch
    fi
    echo ''

    echo '还原暂存'
    git stash pop
else
    echo '暂存区无需还原'
fi


echo ''
git branch
echo ''
echo '操作完成!'
echo ''
git log --oneline -5
echo ''

