current_branch=`git rev-parse --abbrev-ref HEAD`
git fetch
git push --set-upstream origin $current_branch
# git checkout master
