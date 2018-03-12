#!/bin/bash -e

# NOTE: create-topics.sh requires KAFKA_PORT and KAFKA_ZOOKEEPER_CONNECT to be set (see docker-compose.yml)

testCreateTopics() {
	NOW=$(date +%s)

	DEFAULT="default-$NOW"
	KAFKA_CREATE_TOPICS="$DEFAULT:1:1" create-topics.sh

	DEFAULT_EXISTS=$(/opt/kafka/bin/kafka-topics.sh --zookeeper "$KAFKA_ZOOKEEPER_CONNECT" --list --topic "$DEFAULT")
	DEFAULT_POLICY=$(/opt/kafka/bin/kafka-configs.sh --zookeeper "$KAFKA_ZOOKEEPER_CONNECT" --entity-type topics --entity-name "$DEFAULT" --describe | awk -F'cleanup.policy=' '{print $2}')
	DEFAULT_RESULT="$DEFAULT_EXISTS:$DEFAULT_POLICY"

	if [[ "$DEFAULT_RESULT" != "$DEFAULT:" ]]; then
		echo "topic not configured correctly: $DEFAULT_RESULT"
		return 1
	fi

	return 0
}

# mock the netstat call as made by the create-topics.sh script
function netstat() { echo "1 2 3 :$KAFKA_PORT"; }
export -f netstat

testCreateTopics
