#!/bin/bash -e

source test.functions

testLog4jConfig() {
	# Given Log4j overrides are provided
	export KAFKA_LISTENERS=PLAINTEXT://:9092
	export KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181

	export LOG4J_LOGGER_KAFKA=DEBUG

	# When the script is invoked
	source "$START_KAFKA"

	# Then the configuration file is correct
	assertExpectedLog4jConfig "log4j.logger.kafka=DEBUG"
}

testLog4jConfig
