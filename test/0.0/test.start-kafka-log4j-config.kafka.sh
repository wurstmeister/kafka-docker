#!/bin/bash -e

source test.functions

testLog4jConfig() {
	# Given Log4j overrides are provided
	source "/usr/bin/versions.sh"

    # since 3.0.0 there is no --zookeeper option anymore, so we have to use the
    # --bootstrap-server option with a random broker
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