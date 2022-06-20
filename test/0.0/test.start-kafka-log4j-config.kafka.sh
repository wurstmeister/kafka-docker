#!/bin/bash -e

source test.functions

testLog4jConfig() {
	# Given Log4j overrides are provided
	export KAFKA_ADVERTISED_HOST_NAME="testhost"
	export LOG4J_LOGGER_KAFKA=DEBUG
	export log4j_logger_kafka_server_KafkaConfig=WARN

	# When the script is invoked
	source "$START_KAFKA"

	# Then the configuration file is correct
	assertExpectedLog4jConfig "log4j.logger.kafka=DEBUG"
	assertExpectedLog4jConfig "log4j.logger.kafka.server.KafkaConfig=WARN"
}

testLog4jConfig
