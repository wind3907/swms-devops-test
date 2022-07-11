#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

: ${ORACLE_SWMS_USER:? "Missing environment variable" }
: ${ORACLE_SWMS_PASSWORD:? "Missing environment variable" }
: ${LOG_PATH:? "Missing environment variable" }

documentation() {
  cat << Documentation
Usage: $(basename "$0") <sql_file_path>

Environment Variables:
  ORACLE_SWMS_USER      - Username to use in sqlplus
  ORACLE_SWMS_PASSWORD  - Password to use in sqlplus
  LOG_PATH              - Path to store the logs
Documentation
}

sql_file_path="$@"

if [ -z "$sql_file_path" ];
then
  documentation
  exit 1;
fi

export result=0;
sqlplus -l ${ORACLE_SWMS_USER}/${ORACLE_SWMS_PASSWORD} <<DOO >> $LOG_PATH || result=$?
    @${sql_file_path};
DOO

if [ $result -eq 0 ]; then
    echo "INFO: Apply successful, Printing Log"
else
    echo "ERROR: Error found while applying $(basename "$sql_file_path")"
fi

cat $LOG_PATH
exit $result
