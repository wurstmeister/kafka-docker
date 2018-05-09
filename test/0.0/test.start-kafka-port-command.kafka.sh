#!/bin/bash -e

source test.functions

testPortCommand() {
	# Given a port command is provided
	export PORT_COMMAND='f() { echo "12345"; }; f'
	export KAFKA_ADVERTISED_LISTENERS="PLAINTEXT://1.2.3.4:_{PORT_COMMAND}"
	export KAFKA_LISTENERS="PLAINTEXT://:9092"

	# When the script is invoked
	source "$START_KAFKA"

	# Then the configuration uses the value from the command
	assertExpectedConfig 'advertised.listeners=PLAINTEXT://1.2.3.4:12345'
	assertExpectedConfig 'listeners=PLAINTEXT://:9092'
	assertAbsent 'advertised.host.name'
	assertAbsent 'advertised.port'
}

testPortCommand
