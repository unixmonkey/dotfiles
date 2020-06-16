# Load version control information
autoload -Uz vcs_info
precmd() { vcs_info }

# Format the vcs_info_msg_0_ variable
zstyle ':vcs_info:git:*' formats ' (%b)'
 
# Set up the prompt (with git branch name)
setopt PROMPT_SUBST
PROMPT='%F{magenta}%m%F{green}${vcs_info_msg_0_}%F{yellow} %~%F{white}: '

# ASDF
. $(brew --prefix asdf)/asdf.sh
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
  autoload -Uz compinit
  compinit
fi

# Load custom aliases and functions
source ~/.profile