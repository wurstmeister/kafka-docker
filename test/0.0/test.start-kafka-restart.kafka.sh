#!/bin/bash -e

source test.functions

testRestart() {
	# Given a hostname is provided
	export KAFKA_ADVERTISED_HOST_NAME="testhost"

	# When the container is restarted (Script invoked multiple times)
	source "$START_KAFKA"
	source "$START_KAFKA"

	# Then the configuration file only has one instance of the config
	assertExpectedConfig 'advertised.host.name=testhost'
	assertAbsent 'listeners'
}

testRestart
