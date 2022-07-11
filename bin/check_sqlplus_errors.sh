#!/bin/bash
set -eu

[[ $# -lt 1 ]] && { echo "Usage: $(basename $0) log_path"; exit 1; }

TARGET_LOG="$1"

check_errors() {
  if [[ $# < 1 ]]; then
    echo "No listing filename supplied"
    exit 1
  fi

  awk '
  BEGIN {nErrors=0}
  /Make Quitting/            {ReportErr(); next }
  /Stop\./                   {ReportErr(); next }
  /Error /                   {ReportErr(); next }
  /Fatal errors encountered/ {ReportErr(); next }
  /Form not created/         {ReportErr(); next }
  /Fatal/                    {ReportErr(); next }
  /created with compilation errors/ {ReportErr(); next }
  /unable to open file/ {ReportErr(); next }
  END {
    print nErrors " errors found"
    exit (nErrors > 0)
  }
  function ReportErr() {
    print FNR,$0
    nErrors ++
  }' $1
}

ERROR_COUNT="$(check_errors ${TARGET_LOG} | tail -1 | awk '{print $1}')"

if [ $ERROR_COUNT -gt 0 ] ; then
  echo "\nINFO: SWMS Build Failed With $ERROR_COUNT Errors.\n"
  # print out errors
  echo
  echo "Errors found:"
  echo "<line in log | Error Regex>"
  check_errors "${TARGET_LOG}" || exit 1
else
  echo
  echo "INFO: Passed regex error check"
  echo
fi
