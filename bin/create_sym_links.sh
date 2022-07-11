#!/bin/bash
set -euo pipefail
set -x

TARGET=rf
cd $SWMS_HOME/bin
DIRLIST="connect rftcp symbol telxon"
for DIR in $DIRLIST; do
  if [[ ! -h $DIR ]]; then
    if [[ -e $DIR ]]; then
      echo $DIR already exists
      return 1
    else
      echo linking  $TARGET to $DIR
      ln -s $TARGET $DIR
    fi
  else
    echo $DIR already exists as a symbolic link, skipping
  fi
done
