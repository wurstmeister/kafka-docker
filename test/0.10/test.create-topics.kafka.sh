#!/bin/bash -e

# NOTE: create-topics.sh requires KAFKA_PORT and KAFKA_ZOOKEEPER_CONNECT to be set (see docker-compose.yml)

testCreateTopics() {
	NOW=$(date +%s)

	# TOPICS array contains the topic name to create / validate
	# CLEANUP array contains the expected cleanup policy configuration for the topic
	TOPICS[0]="default-$NOW"
	CONFIG[0]=""

	TOPICS[1]="compact-$NOW"
	CONFIG[1]="cleanup.policy=compact,compression.type=snappy"

	KAFKA_CREATE_TOPICS="${TOPICS[0]}:1:1,${TOPICS[1]}:2:1:compact --config=compression.type=snappy" create-topics.sh

	# shellcheck disable=SC1091
	source "/usr/bin/versions.sh"

	# since 3.0.0 there is no --zookeeper option anymore, so we have to use the
	# --bootstrap-server option with a random broker
	if [[ "$MAJOR_VERSION" -ge "3" ]]; then
		CONNECT_OPTS="--bootstrap-server $(echo "${BROKER_LIST}" | cut -d ',' -f1)"
	else
		CONNECT_OPTS="--zookeeper ${KAFKA_ZOOKEEPER_CONNECT}"
	fi

	# Loop through each array, validate that topic exists, and correct configuration is set
	for i in "${!TOPICS[@]}"; do
		TOPIC=${TOPICS[i]}

		echo "Validating topic '$TOPIC'"

		# shellcheck disable=SC2086
		EXISTS=$(/opt/kafka/bin/kafka-topics.sh ${CONNECT_OPTS} --list --topic "$TOPIC")
		# shellcheck disable=SC2086
		ACTUAL_CONFIG=$(/opt/kafka/bin/kafka-configs.sh ${CONNECT_OPTS} --entity-type topics --entity-name "$TOPIC" --describe \
			| cut -d'{' -f1 \
			| grep -oE '(compression.type|cleanup.policy)=([^ ,]+)' \
			| sort \
			| tr '\n' ',' \
			| sed 's/,$//')

		RESULT="$EXISTS:$ACTUAL_CONFIG"
		EXPECTED="$TOPIC:${CONFIG[i]}"

		if [[ "$RESULT" != "$EXPECTED" ]]; then
			echo "$TOPIC topic not configured correctly:"
			echo "    Actual: '$RESULT'"
			echo "  Expected: '$EXPECTED'"
			return 1
		fi
	done

	return 0
}

# mock the netstat call as made by the create-topics.sh script
function netstat() { echo "1 2 3 :$KAFKA_PORT"; }
export -f netstat

testCreateTopics
