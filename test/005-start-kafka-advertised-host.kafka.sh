#!/bin/bash -e

source test.functions

testAdvertisedHost() {
	# Given a hostname is provided
	export KAFKA_ADVERTISED_HOST_NAME=monkey
	export KAFKA_ADVERTISED_PORT=8888
	export KAFKA_HOST_NAME=internal-monkey
	export KAFKA_PORT=2222

	# When the script is invoked
	source "$START_KAFKA"

	# Then the configuration file is correct
	assertExpectedConfig 'advertised.listeners=PLAINTEXT://monkey:8888'
	assertExpectedConfig 'listeners=PLAINTEXT://internal-monkey:2222'
}

testAdvertisedHost
