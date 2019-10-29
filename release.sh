# wait enter some content
# $1: description
function input(){
    while(( 1 == 1 ))
    do
        read -p "    enter $1：" answer
        if [ $answer ]
        then
            echo $answer
            break
        else
            continue
        fi
    done
}


# operate confirm
# $1: tip, -z null adjuctment
function confirm(){
    while(( 1 == 1 ))
    do
        read -p "    $1？y/n/q：" answer
        if [ -z $answer ]
        then
            continue
        fi
        if [ $answer == 'Y' -o $answer == 'y' ]
        then
            echo true
        elif [ $answer == 'N' -o $answer == 'n' ]
        then
            echo false
        elif [ $answer == 'Q' -o $answer == 'q' ]
        then
            exit -1
        else
            continue
        fi
        break
    done
}

appjs_dir='/mnt/d/Project/wxapp'
appjs_file='/mnt/d/Project/wxapp/wxapp/app.js'

cd $appjs_dir
git stash
git checkout master
git pull
grep 'version' $appjs_file
new_version=`input 'new version'`
branch_name=release_$new_version
result=`git branch -a`

# 检查分支是否已存在
if [[ $result =~ $branch_name ]]
then
    echo 分支 $branch_name 已存在！
    echo ''
    answer=$(confirm 'delete old branch and create?')
    echo ''
    if [[ $answer == true ]]
    then
        git branch -D $branch_name
        git push --delete origin $branch_name
    else
        exit -1
    fi
else
    echo 一切正常
fi
git checkout -b $branch_name
sed -i "s/version: \(.*\)'/version: '$new_version'/g" $appjs_file
git add $appjs_file
git commit -m "Release: $new_version"
git push --set-upstream origin $branch_name

echo ''
answer=$(confirm 'merge and make tag?')
echo ''
if [[ $answer == true ]]
then
    git checkout master
    git pull
    git describe --tags --long
else
    echo no push
fi
echo '操作完成!'
