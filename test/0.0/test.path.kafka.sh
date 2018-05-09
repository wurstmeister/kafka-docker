#!/bin/bash -e

# NOTE: this tests to see if the /opt/kafka/bin is existing in the path within the docker container

testPath() {
	echo "Checking PATH '$PATH'"
	if [[ ! "$PATH" =~ "/opt/kafka/bin" ]]; then
		echo "path is not set correctly: $PATH"
		return 1
	fi

	return 0
}

testPath
