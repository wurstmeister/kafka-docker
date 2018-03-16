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
	assertExpectedConfig 'advertised.listeners=PLAINTEXT://:9092'
	assertExpectedConfig 'listeners=PLAINTEXT://:9092'
}

testStartKafka
