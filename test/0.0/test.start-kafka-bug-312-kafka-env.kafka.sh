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
source "/usr/bin/versions.sh"

# since 3.0.0 there is no --zookeeper option anymore, so we have to use the
# --bootstrap-server option with a random broker
if [[ "$MAJOR_VERSION" -ge "3" ]]; then
    echo "this test is obsolete with kafka from version 3.0.0 'advertised.host.name' are removed with Kafka 3.0.0"
    echo "See: https://github.com/apache/kafka/pull/10872"
else
    testKafkaEnv
fi