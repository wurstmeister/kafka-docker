#!/bin/bash -e

source test.functions

testHostnameCommand() {
	# Given a hostname command is provided
	export HOSTNAME_COMMAND='f() { echo "my-host"; }; f'

	# When the script is invoked
	source "$START_KAFKA"

	# Then the configuration uses the value from the command
	assertExpectedConfig 'advertised.host.name=my-host'
	assertAbsent 'advertised.listeners'
	assertAbsent 'listeners'
}

testHostnameCommand
