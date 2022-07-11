#!/bin/bash
set -euo pipefail
set -x

documentation() {
  cat << Documentation
Usage: $(basename "$0")

Environment Variables:
  ORACLE_SID              - System ID of the Database in Oracle
  SWMS_HOME               - The current SWMS installation location or SymLink
Documentation
}

: ${ORACLE_SID:? "Env not set; SID of the database in Oracle"}
: ${SWMS_HOME:? "Environment variable not set; The current SWMS installation location or SymLink"}

[ -z ${ORACLE_SID// } ] && echo "ORACLE_SID cannot be blank";
[ -z ${SWMS_HOME// } ] && echo "SWMS_HOME cannot be blank";

export MAKERULES=
cd ${SWMS_HOME}/rfd/rftcp/smit

# Extract the WinCE artifacts and create test groups
/bin/make -f rf_deploy.mk test_ALL

# Promote to production
# If we want to update the RF info in the DB
if [[ "${HOST%e}" == "$HOST" ]]; then
  export UPDATE_RFINFO=Yes
else
  export UPDATE_RFINFO=No
fi

# If we want to copy the Avalance config in certain models (eg: wt4090)
export COPY_AVA=No

/bin/make -f rf_deploy.mk prod_ALL

# Remove all versions except last two versions
/bin/make -f rf_deploy.mk prune_ALL

# Set permissions and symlinks
chmod -R 750 ${SWMS_HOME}/rfplbin

OPCO=$(hostname | cut -c 3-5)
cd ${SWMS_HOME}/rfplbin
if [[ ! -L $OPCO ]]; then
  ln -f -s . $OPCO
fi
