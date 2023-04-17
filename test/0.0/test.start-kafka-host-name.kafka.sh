#!/bin/bash -e

source test.functions

testHostnameCommand() {
	# Given a hostname command is provided
	export HOSTNAME_COMMAND='f() { echo "my-host"; }; f'

	# When the script is invoked
	source "$START_KAFKA"
	# shellcheck disable=SC1091
	source "/usr/bin/versions.sh"

	# since 3.0.0 there is no KAFKA_ADVERTISED_HOST_NAME
	if [[ "$MAJOR_VERSION" -ge "3" ]]; then
	    # Then the configuration uses the value from the command
		assertExpectedConfig 'advertised.listeners=PLAINTEXT://my-host:9092'
		assertExpectedConfig 'listeners=PLAINTEXT://:9092'
	else
		# Then the configuration uses the value from the command
		assertExpectedConfig 'advertised.host.name=my-host'
		assertAbsent 'advertised.listeners'
		assertAbsent 'listeners'
	fi
}

testHostnameCommand
