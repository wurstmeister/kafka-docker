#!/bin/bash -e

testBrokerList() {
	# Need to get the proxied ports for kafka
	PORT1=$(docker inspect -f '{{ index .NetworkSettings.Ports "9092/tcp" 0 "HostPort" }}' test_kafka_1)
	PORT2=$(docker inspect -f '{{ index .NetworkSettings.Ports "9092/tcp" 0 "HostPort" }}' test_kafka_2)

	RESULT=$(HOST_IP=1.2.3.4 broker-list.sh)

	echo "$RESULT"

	if [[ "$RESULT" == "1.2.3.4:$PORT1,1.2.3.4:$PORT2" || "$RESULT" == "1.2.3.4:$PORT2,1.2.3.4:$PORT1" ]]; then
		return 0
	else
		return 1
	fi
}

testBrokerList
