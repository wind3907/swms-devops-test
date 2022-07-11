#!/bin/bash
set -euo pipefail
set -x


: ${BASE_DIRECTORY:? "Environment variable not set; Base directory path"}

[ -z ${BASE_DIRECTORY// } ] && echo "Base directory path cannot be blank";

if [ $# -ne 0 ]; then
  # [ "$(echo "$1" | tr '[:upper:]' '[:lower:]')" = "help" ] && { documentation; exit 1; }
  documentation
  exit 1
fi

retain_files=(crontab.* swms_oper_daily.* rsync_sts.sh sts_rsync_log_cycle)

if [ `ls -td /swms/base/curr*/ | wc -l` -gt 1 ]; then
  last_install=$(ls -td /swms/base/curr*/ | tail -1)
  cd ${last_install}/bin
  for file in "${retain_files[@]}"
  do
    if [ -n "$(find -name ${file} | head -1)" ];then
      cp ${file} ${SWMS_HOME}/bin
      chmod 750 ${SWMS_HOME}/bin/${file}
    else
      echo "${file} files do not exist. Skipping."
    fi
  done
else 
  echo "No previous installation to copy crontab files"
fi
