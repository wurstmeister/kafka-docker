#!/bin/bash -e

source version.functions

testSnappy() {
	echo 'foo,bar' | eval "kafkacat -X compression.codec=snappy -b $BROKER_LIST $KAFKACAT_OPTS -P -D, -t snappy"
	eval "kafkacat -X compression.codec=snappy -b $BROKER_LIST $KAFKACAT_OPTS -C -e -t snappy"
}

testSnappy
