#!/bin/bash

set -e -o pipefail

echo "Sleeping 5 seconds until Kafka is started"
sleep 5

echo "Checking to see if Kafka is alive"
echo "dump" | nc -w 20 zookeeper 2181 | fgrep "/brokers/ids/"

echo "Check JMX"
curl -s jmxexporter:5556/metrics | grep 'kafka_server_BrokerTopicMetrics_MeanRate{name="MessagesInPerSec",'
