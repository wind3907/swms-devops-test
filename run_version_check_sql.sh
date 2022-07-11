#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

: ${ORACLE_SWMS_USER:? "Missing environment variable" }
: ${ORACLE_SWMS_PASSWORD:? "Missing environment variable" }
: ${LOG_PATH:? "Missing environment variable" }

version_no="$@"

export result=0;
#testvar=$(sqlplus -l ${ORACLE_SWMS_USER}/${ORACLE_SWMS_PASSWORD} @${sql_file_path})
version_dbcol=`sqlplus -s ${ORACLE_SWMS_USER}/${ORACLE_SWMS_PASSWORD} <<!
set pages 0 echo off feed off
select attribute_value
  FROM maintenance m
  WHERE attribute = 'LEVEL'
    AND application = 'SWMS'
    AND component = 'SCHEMA'
    AND create_date = ( SELECT max(create_date)
                          FROM maintenance d
                          WHERE d.attribute = m.attribute
                          AND d.component = m.component
                          AND d.application = m.application
                      );
commit;
!
`
echo "version no passed" $version_no
echo "version no from DB" $version_dbcol
if [ $version_dbcol == $version_no ]; then
    echo "INFO: Deployment Successful, Verssion is correct"
else
    echo "ERROR: Deployment Unsuccessful, Verssion is incorrect"
    result=1;
fi

#cat $LOG_PATH
exit $result
