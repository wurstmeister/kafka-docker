#!/bin/bash -e

source test.functions

testKafkaEnv() {
    # Given required settings are provided
    export KAFKA_ADVERTISED_HOST_NAME="testhost"
    export KAFKA_OPTS="-Djava.security.auth.login.config=/kafka_server_jaas.conf"

    # When the script is invoked
    source "$START_KAFKA"

    # Then env should remain untouched
    if [[ ! "$KAFKA_OPTS" == "-Djava.security.auth.login.config=/kafka_server_jaas.conf" ]]; then
        echo "KAFKA_OPTS not set to expected value. $KAFKA_OPTS"
        exit 1
    fi

    # And the broker config should not be set
    assertAbsent 'opts'

    echo " > Set KAFKA_OPTS=$KAFKA_OPTS"
}

testKafkaEnv
