#!/bin/bash
set -euo pipefail

documentation() {
  cat << Documentation
  Usage: $(basename "$0") <state>

  Changes the state of the swms applications.

  includes: 
    non-prod servers: rftcp, rf-host-service, http-logger
    prod servers: rftcp, rf-host-service, http-logger, swms_start, swmsmon

  Arguments:
    action | start or stop
    env | prod or non_prod
Documentation
}

[ $# -lt 1 ] && { documentation; exit 1; }

action="$1"
if [[ "$action" != "start" ]] && [[ "$action" != "stop" ]]; then
  echo "Invalid action."
  exit 1
fi

env="$2"
if [[ "$env" != "prod" ]] && [[ "$env" != "non_prod" ]]; then
  echo "Invalid environment."
  exit 1
fi

DEPLOYMENT_PLATFORM="$(uname -s)"

lib_dir="$(dirname $0)/../lib"

case "$DEPLOYMENT_PLATFORM" in
  AIX)
    case "$env" in
      "non_prod")
        "$lib_dir"/modify_service.sh "$action" "swms"
        ;;
      "prod")
        "$lib_dir"/modify_service.sh "$action" "swms"
        ;;
    esac
    ;;
  Linux)
    case "$env" in
      "non_prod")
        "$lib_dir"/modify_service.sh "$action" "rftcp.service"
        "$lib_dir"/modify_service.sh "$action" "rf-host-service.service"

        if [ "$action" == "start"  ]; then
          "$lib_dir"/modify_service.sh "$action" "http_logger.service"
          "$lib_dir"/modify_service.sh "$action" "swms-executor.service"
        fi
        ;;
      "prod")
        "$lib_dir"/modify_service.sh "$action" "rftcp.service"
        "$lib_dir"/modify_service.sh "$action" "rf-host-service.service"
        "$lib_dir"/modify_service.sh "$action" "http_logger.service"
        "$lib_dir"/modify_service.sh "$action" "swms_start.service"
        "$lib_dir"/modify_service.sh "$action" "swmsmon.service"
        "$lib_dir"/modify_service.sh "$action" "swms-executor.service"
        ;;
    esac
    ;;
esac
