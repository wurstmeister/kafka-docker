#!/bin/bash -e

source version.functions

testReadWrite() {
	echo 'foo,bar' | eval "kafkacat -b $BROKER_LIST $KAFKACAT_OPTS -P -D, -t readwrite"
	eval "kafkacat -b $BROKER_LIST $KAFKACAT_OPTS -C -e -t readwrite"
}

testReadWrite
