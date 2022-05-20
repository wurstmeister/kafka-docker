#!/bin/bash -e

source test.functions

testRestart() {
	# shellcheck disable=SC1091
	source "/usr/bin/versions.sh"
	# since 3.0.0 KAFKA_ADVERTISED_HOST_NAME was removed
	if [[ "$MAJOR_VERSION" -lt "3" ]]; then
		# Given a hostname is provided
		export KAFKA_ADVERTISED_HOST_NAME="testhost"
	else
        export KAFKA_ADVERTISED_LISTENERS="PLAINTEXT://testhost:9092"
	fi

	# When the container is restarted (Script invoked multiple times)
	source "$START_KAFKA"
	source "$START_KAFKA"

	if [[ "$MAJOR_VERSION" -lt "3" ]]; then
		# Then the configuration file only has one instance of the config
	    assertExpectedConfig 'advertised.host.name=testhost'
	    assertAbsent 'listeners'
	else
	    assertExpectedConfig 'advertised.listeners=PLAINTEXT://testhost:9092'
	    assertAbsent 'listeners'
	fi
}
testRestart