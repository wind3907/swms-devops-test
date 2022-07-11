#!/bin/bash
set -euo pipefail
set -x

. "$(dirname $0)"/service_deployment.sh

documentation() {
  cat << Documentation
  Usage $(basename "$0") <action> <service_name_or_group_name>

  Description: Script to specifically modify the state of a service

  Arguments:
    action                     | start or stop
    service_name_or_group_name | Linux: name of service, AIX: Name of group
Documentation
}

[[ $# -ne 2 ]] && { documentation; exit 1; }
[ -z ${1// } ] && { echo "Action cannot be blank"; exit 1; }
[ -z ${2// } ] && { echo "Service Name or Group Name cannot be blank"; exit 1; }

action=$1
target_name=$2

# AIX or Linux
DEPLOYMENT_PLATFORM="$(uname -s)"

case "$DEPLOYMENT_PLATFORM" in
    AIX*)
      case "$action" in
        start)
          start_aix "$target_name"
          ;;
        stop)
          stop_aix "$target_name"
          ;;
        *)
          echo "Action is invalid: $action"
          exit 1
          ;;
      esac
      ;;
    Linux*)
      case "$action" in
        start)
          start_linux "$target_name"
          ;;
        stop)
          stop_linux "$target_name"
          ;;
        *)
          echo "Action is invalid: $action"
          exit 1
          ;;
      esac
      ;;
    *)
      echo "Unsupported platform: $DEPLOYMENT_PLATFORM. Expecting AIX or Linux."
      exit 1
      ;;
esac
