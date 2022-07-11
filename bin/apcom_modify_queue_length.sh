#!/bin/bash
set -euo pipefail
set -x

documentation() {
  cat << Documentation
    Usage: $(basename $0) <queue_list> <lengths_list>

    Modify's the apcom configuration file to change the
    queue length of the corresponding queue name.
Documentation
}

: ${QUEUE_LIST:? "Environment variable not set" }
: ${LENGTHS_LIST:? "Environment variable not set" }

## Data Verification ##
# Specifically not quoted since we want the string to split out
QUEUES=($QUEUE_LIST)
LENGTHS=($LENGTHS_LIST)

queues_size=${#QUEUES[@]}
lengths_size=${#LENGTHS[@]}

if [[ $queues_size -ne $lengths_size ]]; then
  echo "ERROR: Queue names and queue lengths have different number of elements. Exiting."
  exit 1
fi

if [[ $queues_size -eq 0 ]]; then
  echo "INFO: Change size is 0. Nothing to do. Skipping"
  exit
fi
######################

TMPFILE=/tmp/$LOGNAME.apcom.conf

if [[ -z "$APCOM_HOME" ]]; then
  echo "APCOM_HOME not set, stopping"
  exit 1
fi

if [[ -z "APCOM_CONFIG_FILE" ]]; then
  APCOM_CONFIG_FILE="$APCOM_HOME/curr/etc/apcom.conf"
fi

function is_bad_queue_id {
  bad_id_code='EAPCOM_BAD_QUEID:'
  Q=$1

  $APCOM_HOME/bin/apcomutil -s $Q | grep "$bad_id_code"
}

function QueueIsEmpty {
  typeset Q=$1
  typeset -i RC=0

  EMPTY=$($APCOM_HOME/bin/apcomutil -s $Q | awk '/^Empty: /{print $3}')
  [[ "$EMPTY" != "TRUE" ]] && RC=1

  return $RC
}

function EditQueueRecordLength {
  typeset Q=$1
  typeset LEN=$2
  typeset -i RC=0

  > $TMPFILE

  awk -v Q=$Q -v LEN=$LEN -v TMPFILE=$TMPFILE -F : '
    $1 == Q {
      if ($5 == LEN) {
        print Q " definition found, length " $5 " is correct, definition not changed"
        found = 1
      }
      else {
        printf "%s:%s:%s:%s:%s:%s:\n",$1,$2,$3,$4,LEN,$6 >> TMPFILE
        print "!" $0 >> TMPFILE
        found = 1
        print Q " definition found, length " $5 " changed to " LEN
        next
      }
    }
    {print $0 >> TMPFILE}
    END {
      if (found != 1) {
        print "Error:  " Q " definition not found in input file"
        exit 1
      }
    }
  ' $APCOM_CONFIG_FILE
}

typeset -i I=0

while [[ $I -lt ${queues_size} ]]; do
  Q=${QUEUES[$I]}
  LEN=${LENGTHS[$I]}

  if is_bad_queue_id $Q; then
    echo "ERROR: Given APCOM queid is invalid";
    exit 1
  fi

  QueueIsEmpty $Q
  RC=$?
  if [[ $RC -ne 0 ]]; then
    echo "$Q queue is not empty, exporting to /apcom/export/prod folder"
    if [[ -e /apcom/export/prod/$Q.exp ]]; then
      rm -f /apcom/export/prod/$Q.exp
    fi
    /apcom/curr/bin/apcomexport $Q
  fi

  EditQueueRecordLength $Q $LEN
  RC=$?
  if [[ $RC -ne 0 ]]; then
    echo "$Q queue config change failed, stopping"
    exit 1
  else
    echo "$Q queue config verified or changed"
    cp /apcom/curr/etc/apcom.conf /apcom/curr/etc/apcom_ci_save.conf # 1) Save previous apcom Config
    cp $TMPFILE /apcom/curr/etc/apcom.conf                           # 2) Move queue change into apcom.conf
    cp /apcom/spool/prod/$Q.dat /apcom/spool/prod/$Q.dat_ci_save     # 3) Save the dat file
    rm -f /apcom/spool/prod/$Q.dat                                   # 4) Remove the dat file for recreation
    /apcom/curr/bin/apcomutil -s $Q                                  # 5) Run apcomutil to recreate the queue
  fi

  (( I = I + 1 ))
done
