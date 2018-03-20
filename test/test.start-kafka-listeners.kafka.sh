#!/bin/bash -e

source test.functions

testListeners() {
	# Given a hostname is provided
	export KAFKA_LISTENERS="PLAINTEXT://internal.domain.com:9040"

	# When the script is invoked
	source "$START_KAFKA"

	# Then the configuration file is correct
	assertAbsent 'advertised.host.name'
	assertAbsent 'advertised.port'
	assertAbsent 'advertised.listeners'
	assertExpectedConfig 'listeners=PLAINTEXT://internal.domain.com:9040'
}

testListeners
