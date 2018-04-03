#!/bin/bash -e

source test.functions

testManualBrokerId() {
	echo "testManualBrokerId"

	# Given a Broker Id is provided
	export KAFKA_LISTENERS=PLAINTEXT://:9092
	export KAFKA_BROKER_ID=57

	# When the script is invoked
	source "$START_KAFKA"

	# Then the broker Id is set
	assertExpectedConfig 'broker.id=57'
}

testAutomaticBrokerId() {
	echo "testAutomaticBrokerId"

	# Given no Broker Id is provided
	export KAFKA_LISTENERS=PLAINTEXT://:9092
	unset KAFKA_BROKER_ID

	# When the script is invoked
	source "$START_KAFKA"

	# Then the broker Id is configured to automatic
	assertExpectedConfig 'broker.id=-1'
}

testBrokerIdCommand() {
	echo "testBrokerIdCommand"

	# Given a Broker Id command is provided
	export KAFKA_LISTENERS=PLAINTEXT://:9092
	unset KAFKA_BROKER_ID
	export BROKER_ID_COMMAND='f() { echo "23"; }; f'

	# When the script is invoked
	source "$START_KAFKA"

	# Then the broker Id is the result of the command
	assertExpectedConfig 'broker.id=23'
}


testManualBrokerId \
 && testAutomaticBrokerId \
 && testBrokerIdCommand
