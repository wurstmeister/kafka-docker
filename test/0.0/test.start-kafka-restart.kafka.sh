#!/bin/bash -e

source test.functions

testRestart() {
	# Given a hostname is provided
	export KAFKA_ADVERTISED_HOST_NAME="testhost"

	# When the container is restarted (Script invoked multiple times)
	source "$START_KAFKA"
	source "$START_KAFKA"

	# Then the configuration file only has one instance of the config
	assertExpectedConfig 'advertised.host.name=testhost'
	assertAbsent 'listeners'
}
source "/usr/bin/versions.sh"

# since 3.0.0 there is no --zookeeper option anymore, so we have to use the
# --bootstrap-server option with a random broker
if [[ "$MAJOR_VERSION" -ge "3" ]]; then
    echo "this thes is obsolete with kafka from version 3.0.0 'advertised.host.name' are removed with Kafka 3.0.0"
    echo "See: https://github.com/apache/kafka/pull/10872"
else
    testRestart
fi