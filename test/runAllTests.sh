#!/bin/bash -e

BROKER_LIST=$(./internal-broker-list.sh)
export BROKER_LIST

echo "BROKER_LIST=$BROKER_LIST"

runAll() {
  # Tests that require kafka
  docker-compose run --rm kafkatest

  RESULT=$?
  if [[ $RESULT -eq 0 ]]; then
    # Tests that require kafkacat
    docker-compose run --rm kafkacattest
    RESULT=$?
  fi

  return $RESULT
}

runAll
result=$?
echo "exit status $result"
exit $result
