#!/bin/bash -e

source test.functions

testKafkaOpts() {
    # shellcheck disable=SC1091
    source "/usr/bin/versions.sh"

    # since 3.0.0 there is no KAFKA_ADVERTISED_HOST_NAME
    if [[ "$MAJOR_VERSION" -lt "3" ]]; then
        export KAFKA_ADVERTISED_HOST_NAME="testhost"
    fi
    # Given required settings are provided

    # .. and a CUSTOM_INIT_SCRIPT with spaces
    export CUSTOM_INIT_SCRIPT="export KAFKA_OPTS=-Djava.security.auth.login.config=/kafka_server_jaas.conf"

    # When the script is invoked
    source "$START_KAFKA"

    # Then the custom init script should be evaluated
    if [[ ! "$KAFKA_OPTS" == "-Djava.security.auth.login.config=/kafka_server_jaas.conf" ]]; then
        echo "KAFKA_OPTS not set to expected value. $KAFKA_OPTS"
        exit 1
    fi

    echo "  > Set KAFKA_OPTS=$KAFKA_OPTS"
}

testKafkaOpts