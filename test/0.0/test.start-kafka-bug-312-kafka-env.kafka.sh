#!/bin/bash -e

source test.functions

testKafkaEnv() {
    # shellcheck disable=SC1091
    source "/usr/bin/versions.sh"

    # Given required settings are provided
    export KAFKA_OPTS="-Djava.security.auth.login.config=/kafka_server_jaas.conf"
    # since 3.0.0 KAFKA_ADVERTISED_HOST_NAME was removed
    if [[ "$MAJOR_VERSION" -lt "3" ]]; then

        export KAFKA_ADVERTISED_HOST_NAME="testhost"
    fi

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