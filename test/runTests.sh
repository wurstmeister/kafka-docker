#!/bin/bash -e

runAll() {
  for t in $(ls test-*.sh); do
    echo "testing '$t'"
    ( source $t )
    status=$?
    if [[ -z "$status" || ! "$status" -eq 0 ]]; then
      return $status
    fi
  done

  return $?
}

runAll
result=$?
echo "exit status $result"
exit $result
