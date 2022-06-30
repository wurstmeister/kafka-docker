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

	# shellcheck disable=SC1091
	source "/usr/bin/versions.sh"

	# since 3.0.0 there is no --zookeeper option anymore, so we have to use the
	# --bootstrap-server option with a random broker
	if [[ "$MAJOR_VERSION" -ge "3" ]]; then
		CONNECT_OPTS="--bootstrap-server $(echo "${BROKER_LIST}" | cut -d ',' -f1)"
	else
		CONNECT_OPTS="--zookeeper ${KAFKA_ZOOKEEPER_CONNECT}"
	fi

	# Loop through each array, validate that topic exists
	for i in "${!TOPICS[@]}"; do
		TOPIC=${TOPICS[i]}

		echo "Validating topic '$TOPIC'"

		# shellcheck disable=SC2086
		EXISTS=$(/opt/kafka/bin/kafka-topics.sh ${CONNECT_OPTS} --list --topic "$TOPIC")
		if [[ "$EXISTS" != "$TOPIC" ]]; then
			echo "$TOPIC topic not created"
			return 1
		fi
	done

	return 0
}

# shellcheck disable=SC1091
source "/usr/bin/versions.sh"

# since 3.0.0 there is no KAFKA_PORT option anymore, so we need to find the port by inspecting KAFKA_LISTENERS
if [[ "$MAJOR_VERSION" -ge "3" ]]; then
    PORT=$(echo "$KAFKA_LISTENERS" | awk -F: '{print $3}')
else
    PORT="$KAFKA_PORT"
fi

# mock the netstat call as made by the create-topics.sh script
function netstat() { echo "1 2 3 :$PORT"; }
export -f netstat

testCreateTopicsCustomSeparator
