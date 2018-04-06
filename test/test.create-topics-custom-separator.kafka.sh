#!/bin/bash -e

# NOTE: create-topics.sh requires KAFKA_PORT and KAFKA_ZOOKEEPER_CONNECT to be set (see docker-compose.yml)
testCreateTopicsCustomSeparator() {
	NOW=$(date +%s)

	# TOPICS array contains the topic name to create / validate
	TOPICS[0]="one-$NOW"
	TOPICS[1]="two-$NOW"
	TOPICS[2]="three-$NOW"

	export KAFKA_CREATE_TOPICS_SEPARATOR=$'\n'
	KAFKA_CREATE_TOPICS=$(cat <<-EOF
		${TOPICS[0]}:1:1
		${TOPICS[1]}:1:1
		${TOPICS[2]}:1:1
	EOF
	)
	export KAFKA_CREATE_TOPICS

	create-topics.sh

	# Loop through each array, validate that topic exists
	for i in "${!TOPICS[@]}"; do
		TOPIC=${TOPICS[i]}

		echo "Validating topic '$TOPIC'"

		EXISTS=$(/opt/kafka/bin/kafka-topics.sh --zookeeper "$KAFKA_ZOOKEEPER_CONNECT" --list --topic "$TOPIC")
		if [[ "$EXISTS" != "$TOPIC" ]]; then
			echo "$TOPIC topic not created"
			return 1
		fi
	done

	return 0
}

# mock the netstat call as made by the create-topics.sh script
function netstat() { echo "1 2 3 :$KAFKA_PORT"; }
export -f netstat

testCreateTopicsCustomSeparator
