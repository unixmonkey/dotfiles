#!/usr/bin/env bash

DOTFILES='.profile .gemrc .gitconfig'


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
