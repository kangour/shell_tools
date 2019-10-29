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
        read -p "    enter $1：" answer
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
    branch_name=`input '一个新分支名'`
    current_branch=$branch_name
    git checkout -b $branch_name
fi


result=`git status`
has_committed=false
if [[ ! $result =~ 'Changes to be committed' ]]
then
    echo '尽情的添加需要提交的文件吧'
    exit -1
fi
# 查询文件列表 | 排除未添加的文件 | 获取带空格的文件名 | 去除空格 | 获取最近一级路径和文件名
result=`git status -s | egrep -v "(^\ |^\?)" | egrep -o "(\ .*)" | sed 's/[ ]//g'`
array=(${result// / })
length=${#array[@]}
body=''
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
    echo '多文件提交'
    body=\($current_branch\)
fi
echo 'body='$body


# 选项菜单
commit_type=''
options="feature fix refactor style docs test chore Quit"
select option in $options
do
    if [[ $option == "Quit" ]]
    then
        echo done
        exit
    elif [[ $options =~ $option && $option != '' ]]
    then
        commit_type=$option
        break
    else
        echo bad option
    fi
done
echo 'type='$commit_type


commit_note=`input 'commit message'`
git commit -m "$commit_type$body: $commit_note"
git log --oneline -3
echo '操作完成!'

