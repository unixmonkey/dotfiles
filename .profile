# *****************************************
#  .profile
#
#  Includes lots of nice funtions
#  and aliases to make your command-line
#  experience happy and productive
#
# *****************************************

# Shell coloring
export TERM=xterm
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

# Editor preferences
export EDITOR='vim'
export SVN_EDITOR='vim'
export GIT_EDITOR='vim'
export BUNDLER_EDITOR='code'

# Shortcuts
alias b='bundle exec'
alias st='open -a "Sublime Text" "$@"'
alias clocrails='cloc . --exclude-dir=vendor,index,solr,tmp,script,log --force-lang="Ruby",feature --force-lang="Ruby",sass --force-lang="Ruby",haml'
alias gitx='/Applications/GitX.app/Contents/MacOS/GitX . &'
alias git-browse='/usr/local/git-browse/bin/git-browse'

rubyversion(){
  if [ -e 'Gemfile' ]; then
    if [ "$(type rvm | head -n 1)" == 'rvm is a function' ]; then
      echo "$(rvm-prompt v p g) "
    else
      echo "$(echo "$RUBY_ROOT" | awk -F/ '{print $NF}') "
    fi
  fi
}

git-churn(){
  git log --all -M -C --name-only --format='format:' "$@" | sort | grep -v '^$' | uniq -c | sort | awk 'BEGIN {print "count\tfile"} {print $1 "\t" $2}' | sort -g
}

git-stats(){
  author=${@:-'David Jones'}
  since=${@:-'1970-01-01 00:00:00'}
  echo "Stats for commmits authored by ${author}"
  git log --author="${author}" --since="${since}" --pretty=tformat: --numstat | \
    grep -v spec | \
    gawk '{ add += $1 ; subs += $2 ; loc += $1 - $2 } END { printf "lines added: %s, removed: %s net changed: %s\n",add,subs,loc }' -
}

git-files-changed-since-commit(){
  git diff --name-only ${@}
}

gitbranch(){
  BRANCH='`git branch 2> /dev/null | grep -e ^* | sed -E  s/^\\\\\*\ \(.+\)$/\(\\\\\1\)\ /`'
  if $BRANCH; then
    echo "($BRANCH) "
  fi
}

git-push-branch(){
  CURRENT=$(git branch | grep '\*' | awk '{print $2}')
  git push -u origin "$CURRENT"
}

gpf(){
  CURRENT=$(git branch | grep '\*' | awk '{print $2}')
  git push --force-with-lease origin "$CURRENT"
}


# GIT aliases
alias git-rm-all='git ls-files --deleted | xargs git rm'
alias git-undo-last-commit='git reset --soft HEAD^'
alias git-quick-tag='git tag `date +"%Y%m%d"`-`git rev-parse --short HEAD`'
alias git-reflog='git reflog --pretty="%C(auto)%h %<|(20)%gd %C(blue)%cr%C(reset) %gs (%s)"'
alias gs='git status'
alias gd='git diff --color $@'
alias ga='git add'
alias gb='git branch'
alias gl='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr by %C(bold blue)%an%Cgreen)%Creset" --abbrev-commit --date=relative'
alias gr='git branch --sort=-committerdate --format="%(committerdate:relative)%09%(refname:short)"'
alias gco='git checkout'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias 'g{'='git stash'
alias 'g}'='git stash apply'
alias gpurr='git pull --rebase'
alias gdeleteremotebranch='git push origin --delete $@'
alias gshownew='git fetch && git log ..FETCH_HEAD'
alias gribbon='git tag --force _ribbon origin/master'
alias gcatchup='git log --patch --reverse --topo-order _ribbon..origin/master'
alias git-authors="git log --format='%aN <%aE>' | sort -u"
gcodate() {
  "git checkout $(git rev-list -n 1 --before='$1 00:00' master)"
}

# Print out the most recent stash with `stash`
# Print out 2 stashes ago with `stash 2`
stash() {
  if ! [[ $1 ]]; then
    CMD="git stash show stash@{0} -p"
  else
    CMD="git stash show stash@{$1} -p"
  fi
  echo $CMD
  $CMD
}

# Print out all git stash diffs
stashes() {
  CURRENT=$(git branch | grep '\*' | awk '{print $2}')
  for i in $(git stash list | awk '{print $1}'); do
    if [[ $i =~ ^(stash.+): ]]; then
      echo ${BASH_REMATCH[1]};
      git stash show ${BASH_REMATCH[1]} -p;
    fi
  done
}

alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"

# RAILS
alias migrate='bundle exec rake db:migrate'
s() {
  if [ -e "./bin/rails" ]; then
    ./bin/rails "$@"
  elif [ -e "./script/rails" ]; then
    ./script/rails "$@"
  elif [ -e 'Gemfile' ]; then
    bundle exec rails "$@"
  fi
}
sc() { s console "$@"; }
ss() {
  if [ -e "Procfile.development" ]; then
    echo 'Starting development services from Procfile.development'
    foreman start -f Procfile.development
  elif [ -e "Procfile.dev" ]; then
    echo 'Starting development services from Procfile.dev'
    foreman start -f Procfile.dev
  elif [ -e "Procfile" ]; then
    echo 'Starting services from Procfile'
    foreman start
  else
    echo 'Starting Rails server on localhost'
    s server "$*" --binding=127.0.0.1
  fi
}


rake_route_urls(){
  rake routes | sed -e "1d" -e "s,^[^/]*,,g" | awk '{print $1}' | sort | uniq
}
rake_route_paths(){
  rake routes | sed -e "1d" -e "s,^[/^]*,,g" | awk '{print $1}' | sort | uniq
}

# get size of directories
getsizeofdir() {
  for i in $(ls $1); do
    echo "$i: $(du -ch $i | grep total | sed 's/total//g')";
  done
}

# search through your history
histfind() {
  history |grep "$*"
}

# Use vim for a nice diff tool
vdiff() {
  vim -d "$@"
}

# copy your ssh key to the server for public key authentication
ssh-copykey() {
  cat ~/.ssh/id_rsa.pub | ssh "$1" "mkdir -p ~/.ssh/ && cat - >> ~/.ssh/authorized_keys"
}

# Bash function to find stuff
# $* means take in all arguments
find_in_dir() {
  find . | xargs grep "$@"
}

# uses find to list every file in current directory and
# all subdirectories then counts lines listed
count_files_in_dir() {
  find . -name '' -prune -o -print | wc -l
}

# less with syntax coloring provided by
# pygments (python easy-install pygments)
pless() {
  pygmentize "$1" | less -r
}

# Start simple webrick server for static content in current directory
alias rubyserve='ruby -run -e httpd -- -p 5000 .'
alias nodeserve='http-server -p 8080 .'

# ===========================================================
# = feature && hack && rake test && ship                    =
# = http://reinh.com/blog/2008/08/27/hack-and-and-ship.html =
# ===========================================================

# create new named feature branch and switch to it
feature() {
  git checkout -b "$1"
}

# show commits only this feature branch
feature_commits() {
  CURRENT=$(git branch | grep '\*' | awk '{print $2}')
  echo "Commits in branch \"${CURRENT}\", but not \"master\":"
  git log master.."${CURRENT}" --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset" --abbrev-commit --date=relative
}

# show diff of things in this branch not in master
feature_changes() {
  CURRENT=$(git branch | grep '\*' | awk '{print $2}')
  echo "Commits in branch \"${CURRENT}\", but not \"master\":"
  git diff master.."${CURRENT}"
}

# rebase the current state of master into the feature branch
# and fast-forward your changes on top of that for easy
# conflict resolution (or avoidance)
hack() {
  CURRENT=$(git branch | grep '\*' | awk '{print $2}')
  git checkout master
  git pull origin master
  git checkout "${CURRENT}"
  git rebase master
}

# switch to master and merge the feature changes, then
# change back (in case you want to work more on that feature)
# note: you should run your tests before shipping
ship() {
  CURRENT=$(git branch | grep '\*' | awk '{print $2}')
  git checkout master
  git merge "${CURRENT}"
  git push origin master
  git checkout "${CURRENT}"
}

git-track() {
  git checkout --track origin/"$1"
}

# make a current local git repository into a server repo and push to server
push_local_git_repo_to_server() {
  SERVER_FOLDER=$1 # FORMAT: username@host:~/folder
  CURRENT_FOLDER_NAME=${PWD##*/}
  GIT_REPO_FOLDER_NAME=${CURRENT_FOLDER_NAME}.git
  ORIGIN_SERVER_FOLDER=$(echo "${SERVER_FOLDER}" | awk '{ sub(":","/"); print $1 }')
  mkdir "${GIT_REPO_FOLDER_NAME}"
  cd "${GIT_REPO_FOLDER_NAME}"
  git init --bare
  cd ..
  scp -r "${GIT_REPO_FOLDER_NAME}" "${SERVER_FOLDER}"
  git remote add origin "ssh://${ORIGIN_SERVER_FOLDER}/${GIT_REPO_FOLDER_NAME}"
  git push origin master
  rm -r ./"${GIT_REPO_FOLDER_NAME}"
}

# shallow-clone a repo to count the lines of code and delete
cloc_repo() {
  git clone --depth 1 "$1" temp-linecount-repo &&
  printf "('temp-linecount-repo' will be deleted automatically)\n\n\n" &&
  cloc temp-linecount-repo &&
  rm -rf temp-linecount-repo
}

alias chexology-rails='cd ~/code/github/chexology/chexology-rails'
alias chexology-ios='cd ~/code/github/chexology/chexology-ios'
alias xopen='chexology-ios && xed .'
chexology() {
  osascript -e '
    current_tab("redis-server .")
    new_tab("bin/rails s -b 0.0.0.0")
    new_tab("bin/rails jobs:work")
    new_tab("code .")

    on current_tab(command)
      tell application "Terminal"
        activate
        delay 1
        do script "cd ~/code/github/chexology/chexology-rails" as text in selected tab of front window
        delay 1
        do script command as text in selected tab of front window
        delay 1
      end tell
    end current_tab

    on new_tab(command)
      tell application "Terminal"
        activate
        tell application "System Events"
          keystroke "t" using command down
        end
        my current_tab(command)
      end tell
    end new_tab
  '
}

# This is sometimes needed if the hard drive gets > 90% full, then elastic goes read-only. Clear disk space and run this command.
fix_elasticsearch_read_only() {
  curl -XPUT -H "Content-Type: application/json" http://localhost:9200/_all/_settings -d '{"index.blocks.read_only_allow_delete": null}'
}

ten_times() {
  seq 10 | xargs -Iz $@;
}

fix-displays() {
  LAPTOP_DISPLAY_PARAMS="id:5A0A9DED-3DC9-5699-789D-2B816E45ACC0 res:1792x1120 hz:59 color_depth:4 scaling:on origin:(0,0) degree:0"
  DISPLAY_ONE_PARAMS="id:F2DE74D8-45DB-1235-3A42-D497FF4DFC94 res:2560x1440 hz:59 color_depth:8 scaling:off"
  DISPLAY_TWO_PARAMS="id:929A02C5-AB7A-209D-76E2-89B36F7F13CA res:2560x1440 hz:59 color_depth:8 scaling:off"

  echo "Swapping displays..."
  displayplacer "$LAPTOP_DISPLAY_PARAMS" "$DISPLAY_ONE_PARAMS origin:(-5120,-229) degree:0" "$DISPLAY_TWO_PARAMS origin:(-2560,-229) degree:0"
  echo "\nDid that fix it?"

  if read -q "choice?Y/N:"; then
    echo "\nGreat!"
  else
    echo "\nTrying the other way..."
    displayplacer "$LAPTOP_DISPLAY_PARAMS" "$DISPLAY_ONE_PARAMS origin:(-2560,-229) degree:0" "$DISPLAY_TWO_PARAMS origin:(-5120,-229) degree:0"
  fi

  # Re-arrange windows with Moom shortcut
  osascript -e '
      tell application "System Events"
        keystroke ";" using command down
      end
  '
}

update-chromedriver() {
  echo "Fixing Chrome so it can get software updates again"
  sudo rm -rf ~/Library/Google/GoogleSoftwareUpdate
  echo "\nQuit and re-launch Chrome before continuing"
  echo "\nIs Chrome re-launched yet?"
  if read -q "choice?Y/N"; then
    echo "\nUpdating Homebrew"
    brew update
    echo "\nInstalling updated chromedriver"
    brew upgrade chromedriver
    echo "\nMarking it safe to execute"
    xattr -d com.apple.quarantine /usr/local/bin/chromedriver
    echo "\nDisabling Chrome updates again..."
    sudo chown nobody:nogroup ~/Library/Google/GoogleSoftwareUpdate
    sudo chmod 000 ~/Library/Google/GoogleSoftwareUpdate
    echo "\nDone!"
  else
    echo "\nOK. Quitting."
  fi
}

# Elixir iex history
export ERL_AFLAGS="-kernel shell_history enabled"

# Local bin paths
export PATH="./bin:$PATH"
export PATH="$HOME/.dotfiles/bin:$PATH"

# Homebrew bin paths
export PATH=/usr/local/bin:/usr/local/sbin:$PATH

# Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

# ImageMagick
export PATH="/usr/local/opt/imagemagick@6/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/imagemagick@6/lib"
export CPPFLAGS="-I/usr/local/opt/imagemagick@6/include"

# Needed for MySQL and some other things to compile
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
export PATH="/usr/local/opt/qt@5.5/bin:$PATH"
export PATH="/usr/local/opt/postgresql@9.6/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/openssl@1.1/lib"
export CPPFLAGS="-I/usr/local/opt/openssl@1.1/include"
export LIBRARY_PATH=$LIBRARY_PATH:/usr/local/opt/openssl/lib
export PKG_CONFIG_PATH="/usr/local/opt/readline/lib/pkgconfig"
