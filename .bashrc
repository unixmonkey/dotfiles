# Me and you; we have history, you know?
HISTCONTROL=erasedups
HISTSIZE=100000
shopt -s histappend # when your shell exits, its history is appended to the .bash_history file

# super happy fun prompt showing server name and current directory with purdy colors
function color_my_prompt {
  local __host="\[\033[01;35m\]\h "
  local __pwd="\[\033[0;33m\]\w"
  local __ruby='\[\e[31m\]`rubyversion`'
  local __git_branch='\[\033[0;32m\]`git branch 2> /dev/null | grep -e ^* | sed -E  s/^\\\\\*\ \(.+\)$/\(\\\\\1\)\ /`'
  local __prompt_tail="\[\033[00m\]:"
  local __last_color="\[\033[00m\]"
  export PS1="$__host$__ruby$__git_branch$__pwd$__last_color$__prompt_tail "
}
color_my_prompt

# Load custom aliases and functions
source ~/.profile

# asdf-vm
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash

