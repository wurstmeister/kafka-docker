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
source "/usr/bin/versions.sh"

# since 3.0.0 there is no --zookeeper option anymore, so we have to use the
# --bootstrap-server option with a random broker
if [[ "$MAJOR_VERSION" -ge "3" ]]; then
    echo "this thes is obsolete with kafka from version 3.0.0 'advertised.host.name' are removed with Kafka 3.0.0"
    echo "See: https://github.com/apache/kafka/pull/10872"
else
    testHostnameCommand
fi