#!/bin/bash -e

source test.functions

testRestart() {
	# Given a hostname is provided
	export KAFKA_LISTENERS="PLAINTEXT://:9092"

	# When the container is restarted (Script invoked multiple times)
	source "$START_KAFKA"
	source "$START_KAFKA"

	# Then the configuration file only has one instance of the config
	assertExpectedConfig 'listeners=PLAINTEXT://:9092'
}

testRestart
