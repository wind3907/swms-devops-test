#!/bin/bash
set -euo pipefail
set -x


documentation() {
	cat << Documentation
Usage: $(basename "$0")

Environment Variables:
  SWMS_VERSION            - The SWMS version that is installed
  SWMS_ARTIFACT_PATH      - Location of the tar gz file to install
Documentation
}

: ${SWMS_ARTIFACT_PATH:? "Environment variable not set; Name of the artifact"}

[ -z ${SWMS_ARTIFACT_PATH// } ] && echo "SWMS_ARTIFACT_PATH cannot be blank";

: ${SWMS_VERSION:? "Environment variable not set; The SWMS version"}

[ -z ${SWMS_VERSION// } ] && echo "SWMS_VERSION cannot be blank";

: ${BASE_DIRECTORY:? "Environment variable not set; Base directory path"}

[ -z ${BASE_DIRECTORY// } ] && echo "Base directory path cannot be blank";

if [ $# -ne 0 ]; then
  # [ "$(echo "$1" | tr '[:upper:]' '[:lower:]')" = "help" ] && { documentation; exit 1; }
  documentation
  exit 1
fi

SWMS_DIRECTORY="$BASE_DIRECTORY/curr_$SWMS_VERSION"

if [[ -d ${SWMS_DIRECTORY} ]]; then
  mv ${SWMS_DIRECTORY} "${SWMS_DIRECTORY}_$(date +%Y%m%d%H%M%S)"
fi

if [[ -n "$(ls -d ${BASE_DIRECTORY}/curr_*)" ]]; then
  ls -dr ${BASE_DIRECTORY}/curr* | tail -n +2 | xargs rm -rf
fi

# Create new install directory
mkdir -p ${SWMS_DIRECTORY}

# Extract artifact to install directory
gunzip -c "$SWMS_ARTIFACT_PATH" | tar -x -v -p -f - -C ${SWMS_DIRECTORY}

# Change permissions of installed files
chmod -R go-w ${SWMS_DIRECTORY}

# Remove current symbolic link and create new onw
if [[ -d ${SWMS_HOME} ]]; then
  rm ${SWMS_HOME}
fi

ln -fs ${SWMS_DIRECTORY} ${SWMS_HOME}
