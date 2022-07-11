#!/bin/bash
set -euo pipefail

documentation() {
  cat << Documentation
Usage: $(basename "$0") <sql_file_path>
Environment Variables:
  DBA_CONN_STRING      - Connection string to be used with sqlplus to login as DBA

Must run with oracle user if above not set
Documentation
}

: ${DBA_CONN_STRING:="/ as sysdba"}

[ -z ${DBA_CONN_STRING// } ] && echo "DBA_CONN_STRING cannot be blank";

sql_file_path="$@"

if [ -z "$sql_file_path" ];then
  documentation
  exit 1;
fi

if [ ${DBA_CONN_STRING} = "/ as sysdba" ]; then
  [ "$(whoami)" != "oracle" ] && { echo "ERROR: Please run as oracle"; exit 1; }
fi

# Run SQL file
sqlplus /nolog <<DOO
  conn ${DBA_CONN_STRING}
  show user
  set echo on
  var rc number;
  whenever sqlerror exit :rc;
  exec :rc:=1;
  @${sql_file_path};
  exec :rc:=0;
  exit :rc;
DOO
