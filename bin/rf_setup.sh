#!/bin/bash
set -euo pipefail
set -x

if [[ "$(uname -s)" == "Linux" ]]; then
  chmod go+rx /var/log/rf-host-service
else
  chmod go+rx /var/adm/rf-host-service
fi

OPCO=$(hostname | cut -c 3-5)
cd /tmp/swms/rf_upload
if [[ ! -L $OPCO ]]; then
  ln -f -s . $OPCO
fi
