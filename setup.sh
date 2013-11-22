#!/usr/bin/env bash

DOTFILES='.gemrc .gitconfig .gitignore_global .irbrc .profile .vimrc'

# Make ~/.vim/backup folder for .swp files
mkdir -p ~/.vim/backup


PWD=${PWD##*/}
NOW=`date +%Y-%m-%d-%H%M%S`

# create dated backup directory
BAKDIR="./backup/${NOW}"
mkdir -p ${BAKDIR}

for DOTFILE in ${DOTFILES}; do
  if [ -e ~/${DOTFILE} ]; then
    echo "Moving original ~/${DOTFILE} to ${BAKDIR}"
    mv ~/${DOTFILE} ${BAKDIR}
  fi

  echo "Symlinking ~/${DOTFILE} to ${PWD}/${DOTFILE}"
  ln -s ${PWD}/$DOTFILE ~/${DOTFILE}
done

echo "Copying Sublime Text Preferences"
ST2PREF="Library/Application Support/Sublime Text 3/Packages/User/Preferences.sublime-settings"
if [ -e ~/"${ST2PREF}" ]; then
  mv ~/"${ST2PREF}" ${BAKDIR}
fi
ln -s ~/${PWD}/Preferences.sublime-settings ~/"${ST2PREF}"


