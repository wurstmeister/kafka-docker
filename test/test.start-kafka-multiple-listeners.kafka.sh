#!/bin/bash -e
source test.functions

testMultipleAdvertisedListeners() {
	# Given multiple advertised listeners
	export HOSTNAME_COMMAND="f() { echo 'monkey.domain'; }; f"
	export KAFKA_ADVERTISED_LISTENERS="INSIDE://:9092,OUTSIDE://_{HOSTNAME_COMMAND}:9094"
	export KAFKA_LISTENERS="INSIDE://:9092,OUTSIDE://:9094"
	export KAFKA_LISTENER_SECURITY_PROTOCOL_MAP="INSIDE:PLAINTEXT,OUTSIDE:PLAINTEXT"
	export KAFKA_INTER_BROKER_LISTENER_NAME="INSIDE"

	# When the script is invoked
	source "$START_KAFKA"

	# Then the configuration file is correct
	assertAbsent "advertised.host.name"
	assertAbsent "advertised.port"

	assertExpectedConfig "advertised.listeners=INSIDE://:9092,OUTSIDE://monkey.domain:9094"
	assertExpectedConfig "listeners=INSIDE://:9092,OUTSIDE://:9094"
	assertExpectedConfig "listener.security.protocol.map=INSIDE:PLAINTEXT,OUTSIDE:PLAINTEXT"
	assertExpectedConfig "inter.broker.listener.name=INSIDE"
}

testMultipleAdvertisedListeners
