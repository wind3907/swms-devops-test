#!/bin/bash
set -euo pipefail
set -x

# Create sqlplus link if DB is 19c
if [ "$(uname -s)" == "AIX" ] && [ "$ORACLE_HOME" = *19.0.0* ]; then
  if [[ ! -e ${SWMS_HOME}/bin/sqlplus ]]; then
    ln -s ${SWMS_HOME}/bin/sqlplus_osauth ${SWMS_HOME}/bin/sqlplus
    echo "Did not find sqlplus; Link created"
  fi
  if [[ ! -e ${SWMS_HOME}/bin/sqlldr ]]; then
    ln -s ${SWMS_HOME}/bin/sqlldr_osauth ${SWMS_HOME}/bin/sqlldr
    echo "Did not find sqlldr; Link created"
  fi
else
  echo "Skipping AIX 19c Setup"
fi
