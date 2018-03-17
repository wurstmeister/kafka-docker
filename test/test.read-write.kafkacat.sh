#!/bin/bash -e

testReadWrite() {
	echo 'foo,bar' | kafkacat -b "$BROKER_LIST" -P -D, -t readwrite
	kafkacat -b "$BROKER_LIST" -C -e -t readwrite
}

testReadWrite
