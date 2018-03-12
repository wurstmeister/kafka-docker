#!/bin/bash -e

PATTERN=$1

echo ""
echo ""
echo "Running tests for pattern $PATTERN"

runPattern() {
  for t in $PATTERN; do
    echo
    echo "===================================="
    echo "testing '$t'"
    # shellcheck disable=SC1090
    ( source "$t" )
    status=$?
    if [[ -z "$status" || ! "$status" -eq 0 ]]; then
      return $status
    fi
  done

  return $?
}

runPattern

exit $?
