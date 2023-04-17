#!/bin/bash -e

source test.functions

testAdvertisedHost() {
	# Given a hostname is provided
	export KAFKA_ADVERTISED_HOST_NAME=monkey
	export KAFKA_ADVERTISED_PORT=8888

	# When the script is invoked
	source "$START_KAFKA"

	# Then the configuration file is correct
	assertExpectedConfig "advertised.host.name=monkey"
	assertExpectedConfig "advertised.port=8888"
	assertAbsent 'advertised.listeners'
	assertAbsent 'listeners'
}
# shellcheck disable=SC1091
source "/usr/bin/versions.sh"

# since 3.0.0 there is no --zookeeper option anymore, so we have to use the
# --bootstrap-server option with a random broker
if [[ "$MAJOR_VERSION" -ge "3" ]]; then
    echo "with kafka from version 3.0.0 'advertised.port' and 'advertised.host.name' are removed, making this test obosolete"
    echo "See: https://github.com/apache/kafka/pull/10872"
else
    testAdvertisedHost
fi