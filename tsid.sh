#!/bin/bash
set -euo pipefail

: ${SWMS_HOME:? "Environment variable not set" }
: ${TSID_FILES:? "Environment variable not set" }

# Gives root privilages to specific swms programs such as rftcp subsystem and FRM_login
tsid 'A'

RC=0

# Convert to bash array
temp_ifs=$IFS
IFS=','
read -r target_files <<< $TSID_FILES
IFS=$temp_ifs
SETUID_FILES=($target_files)

if [[ ${#SETUID_FILES[@]} -eq 0 ]]; then
  echo "INFO: File list size is 0. Nothing to do. Skipping"
  exit
fi

DIR="$SWMS_HOME"/bin

echo "\nChecking SWMS SETUID files:"
for file in ${SETUID_FILES[@]}; do
  /bin/ls -ls $DIR/"$file"
  if [[ ! -u $DIR/"$file" || ! -g $DIR/"$file" ]]; then
    echo "\t*** Failed"
    RC=1
  fi
done

exit $RC
