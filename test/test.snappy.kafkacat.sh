#!/bin/bash -e

testSnappy() {
	echo 'foo,bar' | kafkacat -X compression.codec=snappy -b "$BROKER_LIST" -P -D, -t snappy
	kafkacat -X compression.codec=snappy -b "$BROKER_LIST" -C -e -t snappy
}

testSnappy
