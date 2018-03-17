#!/bin/bash -e

source test.functions

testAdvertisedListeners() {
	# Given a hostname is provided
	EXPLICIT_ADVERTISED_LISTENERS="PLAINTEXT://my.domain.com:9040"
	export KAFKA_ADVERTISED_LISTENERS="$EXPLICIT_ADVERTISED_LISTENERS"

	# When the script is invoked
	source "$START_KAFKA"

	# Then the configuration file is correct
	assertExpectedConfig 'advertised.listeners=PLAINTEXT://my.domain.com:9040'
	assertExpectedConfig 'listeners=PLAINTEXT://:9092'
}

testAdvertisedListeners
