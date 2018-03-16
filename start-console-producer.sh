#!/bin/bash
# Use this script in a kafka shell instance to create a simple producer that reads from stdin and published to the given topic.

if [[ -z "$1" ]]; then
    echo 'Usage:' $0 '<topic_name>'
	exit 1;
fi

$KAFKA_HOME/bin/kafka-console-producer.sh --topic=$1 --broker-list=`broker-list.sh`