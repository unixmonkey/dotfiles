# *****************************************
#  .profile
#
#  Includes lots of nice funtions
#  and aliases to make your command-line
#  experience happy and productive
#
# *****************************************

# Me and you; we have history, you know?
HISTCONTROL=erasedups
HISTSIZE=100000
shopt -s histappend # when your shell exits, its history is appended to the .bash_history file

export PATH=/usr/local/bin:/usr/local/sbin:$PATH

# set editor preferences
export EDITOR='vim'
export SVN_EDITOR='vim'
export GIT_EDITOR='vim'
export BUNDLER_EDITOR='subl -w'
function e(){
  subl -n $*
}

# super happy fun prompt showing server name and current directory with purdy colors
export TERM=xterm
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad
function color_my_prompt {
  local __host="\[\033[01;35m\]\h"
  local __pwd="\[\033[0;33m\]\w"
  local __ruby_color="\[\e[31m\]"
  local __ruby='\[\e[31m\]`rubyversion`'
  local __git_branch='\[\033[0;32m\]`git branch 2> /dev/null | grep -e ^* | sed -E  s/^\\\\\*\ \(.+\)$/\(\\\\\1\)\ /`'
  local __prompt_tail="\[\033[00m\]:"
  local __last_color="\[\033[00m\]"
  export PS1="$__host $__ruby $__git_branch$__pwd$__last_color$__prompt_tail "
}
color_my_prompt

# Shortcuts
alias code='cd ~/code'
alias b='bundle exec'
alias bake='bundle exec rake'
alias st='open -a "Sublime Text" "$@"'
alias clocrails='cloc . --exclude-dir=vendor,index,solr,tmp,script,log --force-lang="Ruby",feature --force-lang="Ruby",sass --force-lang="Ruby",haml'
alias gitx='/Applications/GitX.app/Contents/MacOS/GitX'

autopatch_intranet() {
  git format-patch HEAD~1
  for SERVER in 'iceman' 'cyclops' 'mystique'; do
    echo "Sending patch to $SERVER"
    scp *.patch root@$SERVER:~/intranet
  done
  shit
}

rubyversion(){
  echo "$(echo $RUBY_ROOT | awk -F/ '{print $NF}')"
}

git-churn(){
  git log --all -M -C --name-only --format='format:' "$@" | sort | grep -v '^$' | uniq -c | sort | awk 'BEGIN {print "count\tfile"} {print $1 "\t" $2}' | sort -g
}

git-stats(){
  git log --author="David Jones" --pretty=tformat: --numstat | \
    grep -v spec | \
    gawk '{ add += $1 ; subs += $2 ; loc += $1 - $2 } END \
    { printf "lines added: %s, removed: %s net changed: %s\n",add,subs,loc }' -
}

gitbranch(){
  BRANCH='`git branch 2> /dev/null | grep -e ^* | sed -E  s/^\\\\\*\ \(.+\)$/\(\\\\\1\)\ /`'
  if $BRANCH; then
    echo "($BRANCH) "
  fi
}

git-push-branch(){
  CURRENT=`git branch | grep '\*' | awk '{print $2}'`
  git push -u origin $CURRENT
}

# GIT aliases
alias git-rm-all='git ls-files --deleted | xargs git rm'
alias git-undo-last-commit='git reset --soft HEAD^'
alias gs='git status'
alias gd='git diff'
alias ga='git add'
alias gb='git branch'
alias gl='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr by %C(bold blue)%an%Cgreen)%Creset" --abbrev-commit --date=relative'
alias gco='git checkout'
alias gcm='git commit -m'
alias g{='git stash'
alias g}='git stash apply'
alias gpurr='git pull --rebase'
alias gshownew='git fetch && git log ..FETCH_HEAD'
alias gribbon='git tag --force _ribbon origin/master'
alias gcatchup='git log --patch --reverse --topo-order _ribbon..origin/master'


# RAILS
s() {
  if [ -e "script/$1" ]; then
    ./script/$*
  else
    bundle exec rails $*
  fi
}
sc() { s console $*; }
ss() {
  if [ -e "Procfile.development" ]; then
    echo 'Starting development services from Procfile.development'
    foreman start -f Procfile.development
  elif [ -e "Procfile" ]; then
    echo 'Starting services from Procfile'
    foreman start
  else
    echo 'Starting Rails server on localhost'
    s server $* --binding=127.0.0.1
  fi
}

rake_route_urls(){
  rake routes | sed -e "1d" -e "s,^[^/]*,,g" | awk '{print $1}' | sort | uniq
}
rake_route_paths(){
  rake routes | sed -e "1d" -e "s,^[/^]*,,g" | awk '{print $1}' | sort | uniq
}


# search through your history
histfind() {
  history |grep "$*"
}

# Use vim for a nice diff tool
vdiff() {
  vim -d $*
}

# copy your ssh key to the server for public key authentication
ssh-copykey() {
  cat ~/.ssh/id_rsa.pub | ssh $1 "mkdir -p ~/.ssh/ && cat - >> ~/.ssh/authorized_keys"
}

# Bash function to find stuff
# $* means take in all arguments
find_in_dir() {
  find . | xargs grep $*
}

# uses find to list every file in current directory and
# all subdirectories then counts lines listed
count_files_in_dir() {
  find . -name '' -prune -o -print | wc -l
}

# less with syntax coloring provided by
# pygments (python easy-install pygments)
pless() {
  pygmentize $1 | less -r
}


# ===========================================================
# = feature && hack && rake test && ship                    =
# = http://reinh.com/blog/2008/08/27/hack-and-and-ship.html =
# ===========================================================

# create new named feature branch and switch to it
feature() {
  git checkout -b $1
}

# show commits only this feature branch
feature_commits() {
  CURRENT=`git branch | grep '\*' | awk '{print $2}'`
  echo "Commits in branch \"${CURRENT}\", but not \"master\":"
  git log master..${CURRENT} --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset" --abbrev-commit --date=relative
}

# show diff of things in this branch not in master
feature_changes() {
  CURRENT=`git branch | grep '\*' | awk '{print $2}'`
  echo "Commits in branch \"${CURRENT}\", but not \"master\":"
  git diff master..${CURRENT}
}

# rebase the current state of master into the feature branch
# and fast-forward your changes on top of that for easy
# conflict resolution (or avoidance)
hack() {
  CURRENT=`git branch | grep '\*' | awk '{print $2}'`
  git checkout master
  git pull origin master
  git checkout ${CURRENT}
  git rebase master
}

# switch to master and merge the feature changes, then
# change back (in case you want to work more on that feature)
# note: you should run your tests before shipping
ship() {
  CURRENT=`git branch | grep '\*' | awk '{print $2}'`
  git checkout master
  git merge ${CURRENT}
  git push origin master
  git checkout ${CURRENT}
}

git-track() {
  git checkout --track origin/$1
}

# make a current local git repository into a server repo and push to server
push_local_git_repo_to_server() {
  SERVER_FOLDER=$1 # FORMAT: username@host:~/folder
  CURRENT_FOLDER_NAME=${PWD##*/}
  GIT_REPO_FOLDER_NAME=${CURRENT_FOLDER_NAME}.git
  ORIGIN_SERVER_FOLDER=`echo ${SERVER_FOLDER} | awk '{ sub(":","/"); print $1 }'`
  mkdir ${GIT_REPO_FOLDER_NAME}
  cd ${GIT_REPO_FOLDER_NAME}
  git init --bare
  cd ..
  scp -r ${GIT_REPO_FOLDER_NAME} ${SERVER_FOLDER}
  git remote add origin ssh://${ORIGIN_SERVER_FOLDER}/${GIT_REPO_FOLDER_NAME}
  git push origin master
  rm -r ./${GIT_REPO_FOLDER_NAME}
}

# load chruby
source /usr/local/opt/chruby/share/chruby/chruby.sh
source /usr/local/opt/chruby/share/chruby/auto.sh

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"
