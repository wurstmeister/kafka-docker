#!/bin/bash -e

# NOTE: create-topics.sh requires KAFKA_PORT and KAFKA_ZOOKEEPER_CONNECT to be set (see docker-compose.yml)

testCreateTopics() {
	NOW=$(date +%s)

	# TOPICS array contains the topic name to create / validate
	# CLEANUP array contains the expected cleanup policy configuration for the topic
	TOPICS[0]="default-$NOW"
	CLEANUP[0]=""

	TOPICS[1]="compact-$NOW"
	CLEANUP[1]="compact"

	KAFKA_CREATE_TOPICS="${TOPICS[0]}:1:1,${TOPICS[1]}:2:1:compact" create-topics.sh

	# Loop through each array, validate that topic exists, and correct cleanup policy is set
	for i in "${!TOPICS[@]}"; do
		TOPIC=${TOPICS[i]}

		echo "Validating topic '$TOPIC'"

		EXISTS=$(/opt/kafka/bin/kafka-topics.sh --zookeeper "$KAFKA_ZOOKEEPER_CONNECT" --list --topic "$TOPIC")
		POLICY=$(/opt/kafka/bin/kafka-configs.sh --zookeeper "$KAFKA_ZOOKEEPER_CONNECT" --entity-type topics --entity-name "$TOPIC" --describe | awk -F'cleanup.policy=' '{print $2}')

		RESULT="$EXISTS:$POLICY"
		EXPECTED="$TOPIC:${CLEANUP[i]}"

		if [[ "$RESULT" != "$EXPECTED" ]]; then
			echo "$TOPIC topic not configured correctly: '$RESULT'"
			return 1
		fi
	done

	return 0
}

# mock the netstat call as made by the create-topics.sh script
function netstat() { echo "1 2 3 :$KAFKA_PORT"; }
export -f netstat

testCreateTopics
