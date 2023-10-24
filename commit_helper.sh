# wait enter some content
# $1: description
function input(){
    if [ $# -ne 1 ]    #"$#"是入参的数量
    then
        echo "参数不足 $0"
        exit 1
    fi
    while(( 1 == 1 ))
    do
        read -p "$1: " answer
        if [ "$answer" ]
        then
            echo "$answer"
            break
        else
            continue
        fi
    done
}


current_branch=`git rev-parse --abbrev-ref HEAD`
if [[ $current_branch == 'master' ]]
then
    echo '当心！master 分支不允许提交'
    current_branch=`input '一个新分支'`
    git checkout -b $current_branch
fi


result=`git status`
has_committed=false

if [[ ! $result =~ 'Changes to be committed' ]]
then
    echo ''
    echo 'add some change: git add <filename>'
    echo ''

    if [[ ! $result =~ '要提交的变更' ]]
    then
        echo ''
        echo 'add some change: git add <filename>'
        echo ''
        exit 1
    fi
fi


# 查询文件列表 | 排除未添加的文件 | 获取带空格的文件名 | 去除空格 | 获取最近一级路径和文件名
result=`git status -s | egrep -v "(^\ |^\?)" | egrep -o "(\ .*)" | sed 's/[ ]//g'`
array=(${result// / })
length=${#array[@]}
body=''
echo 本次提交 $length 个文件
if [[ $length == 1 ]]
then
    array=(${result//\// })
    length=${#array[@]}
    if [[ $length == 1 ]]
    then
        body=$result
    else
        body=${array[length-2]}/${array[length-1]}
    fi
    body=\($body\)
else
    body=''
fi
echo ''
echo commit body: $body
echo ''


# 选项菜单
commit_type=''
options="feat fix refactor test style docs chore perf ci Quit"
select option in $options
do
    if [[ $option == "Quit" ]]
    then
        echo ''
        echo quit commit.
        echo ''
        exit -1
    elif [[ $options =~ $option && $option != '' ]]
    then
        commit_type=$option
        break
    else
        echo ''
        echo bad option!
        echo ''
    fi
done
echo ''
echo commit type: $commit_type
echo ''


commit_note=`input 'commit message'`
git commit -m "$commit_type$body: $commit_note"
echo ''
git log --oneline -6
echo ''

