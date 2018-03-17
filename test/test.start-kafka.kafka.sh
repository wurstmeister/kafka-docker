#!/bin/bash -e

source test.functions

testStartKafka() {
	# Given no additional environment set
	unset KAFKA_ADVERTISED_HOST_NAME
	unset KAFKA_ADVERTISED_LISTENERS
	unset KAFKA_LISTENERS

	# When the script is invoked
	source "$START_KAFKA"

	# Then the configuration file is correct
	assertAbsent 'advertised.listeners'
	assertExpectedConfig 'listeners=PLAINTEXT://:9092'
}

testStartKafka
