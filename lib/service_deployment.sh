#!/bin/bash
set -euo pipefail

# Each stop sequence will wait 30 seconds.

# TODO: Should I also put protections on the variables in this file? <30-03-22, Michael Chen> #
stop_linux() {
  service_name="$1"

  trap 'print Interrupted' INT

  sudo systemctl stop "$service_name"

  typeset -i LIMIT=30
  typeset -i COUNT=1

  while [[ $COUNT -le $LIMIT && $(systemctl status "$service_name" |grep -v grep|grep -i -c "Active: deactivating") -ne 0 ]]; do
    echo "Waiting for shutdown, count $COUNT/$LIMIT"
    sleep 1
    ((COUNT = COUNT + 1))
  done

  trap - 2  #reset SIGINT trap

  if [[ $COUNT -gt $LIMIT ]]; then
    echo "Timed out waiting for subsystems to stop"
    exit 1
  fi
}

start_linux() {
  service_name="$1"

  trap 'print Interrupted' INT

  echo "\nStarting swms subsystems..."
  sudo systemctl start "$service_name"
  echo

  systemctl status "$service_name"
  trap - 2  #reset SIGINT trap
}

stop_aix() {
  group_name="$1"

  if [[ $(lssrc -g "$group_name"| grep -i -c active) < 1 ]]; then
    echo "Subsystems are already shutdown. Skipping shutdown."
    return 0
  fi

  trap 'print Interrupted' INT
  sudo stopsrc -g "$group_name"

  typeset -i LIMIT=30
  typeset -i COUNT=1

  while [[ $COUNT -le $LIMIT && $(lssrc -g "$group_name"|grep -v grep|grep -i -c stopping) -ne 0 ]]; do
    echo "Waiting for shutdown, count $COUNT/$LIMIT"
    sleep 1
    ((COUNT = COUNT + 1))
  done

  trap - 2  #reset SIGINT trap

  if [[ $COUNT -gt $LIMIT ]]; then
    echo "Timed out waiting for subsystems to stop"
    exit 1
  fi
}

start_aix() {
  group_name="$1"

  trap 'print Interrupted' INT

  echo "\nStarting swms subsystems..."
  sudo startsrc -g "$group_name"
  echo

  lssrc -g "$group_name"
  trap - 2  #reset SIGINT trap
}
