#!/bin/bash -e

source test.functions

testLog4jConfig() {
	# Given Log4j overrides are provided
	# shellcheck disable=SC1091
	source "/usr/bin/versions.sh"

	# since 3.0.0 there is no KAFKA_ADVERTISED_HOST_NAME
	if [[ "$MAJOR_VERSION" -lt "3" ]]; then
		export KAFKA_ADVERTISED_HOST_NAME="testhost"
	fi

	export LOG4J_LOGGER_KAFKA=DEBUG

	# When the script is invoked
	source "$START_KAFKA"

	# Then the configuration file is correct
	assertExpectedLog4jConfig "log4j.logger.kafka=DEBUG"
}
testLog4jConfig