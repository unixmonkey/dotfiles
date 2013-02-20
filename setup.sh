#!/usr/bin/env bash

DOTFILES='.gemrc .gitconfig .irbrc .profile .vimrc'

# Make ~/.vim/backup folder for .swp files
mkdir -p ~/.vim/backup


PWD=${PWD##*/}
NOW=`date +%Y-%m-%d-%H%M%S`

for DOTFILE in ${DOTFILES}; do
  if [ -e ~/${DOTFILE} ]; then

    # create dated backup directory
    BAKDIR="./backup/${NOW}"
    mkdir -p ${BAKDIR}

    echo "Moving original ~/${DOTFILE} to ${BAKDIR}"
    mv ~/${DOTFILE} ${BAKDIR}
  fi
  
  echo "Symlinking ~/${DOTFILE} to ${PWD}/${DOTFILE}"
  ln -s ${PWD}/$DOTFILE ~/${DOTFILE}
done
