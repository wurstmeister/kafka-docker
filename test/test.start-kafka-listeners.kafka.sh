#!/bin/bash -e

source test.functions

testListeners() {
	# Given a hostname is provided
	EXPLICIT_LISTENERS="PLAINTEXT://my.domain.com:9040"
	export KAFKA_LISTENERS="$EXPLICIT_LISTENERS"

	# When the script is invoked
	source "$START_KAFKA"

	# Then the configuration file is correct
	assertAbsent 'advertised.listeners'
	assertExpectedConfig 'listeners=PLAINTEXT://my.domain.com:9040'
}

testListeners
