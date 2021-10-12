#!/bin/bash

if [[ -z "$KAFKA_CREATE_TOPICS" ]]; then
    exit 0
fi

if [[ -z "$START_TIMEOUT" ]]; then
    START_TIMEOUT=600
fi

start_timeout_exceeded=false
count=0
step=10
while netstat -lnt | awk '$4 ~ /:'"$KAFKA_PORT"'$/ {exit 1}'; do
    echo "waiting for kafka to be ready"
    sleep $step;
    count=$((count + step))
    if [ $count -gt $START_TIMEOUT ]; then
        start_timeout_exceeded=true
        break
    fi
done

if $start_timeout_exceeded; then
    echo "Not able to auto-create topic (waited for $START_TIMEOUT sec)"
    exit 1
fi

# introduced in 0.10. In earlier versions, this will fail because the topic already exists.
# shellcheck disable=SC1091
source "/usr/bin/versions.sh"
if [[ "$MAJOR_VERSION" == "0" && "$MINOR_VERSION" -gt "9" ]] || [[ "$MAJOR_VERSION" -gt "0" ]]; then
    KAFKA_0_10_OPTS="--if-not-exists"
fi

# since 3.0.0 there is no --zookeeper option anymore, so we have to use the
# --bootstrap-server option with a random broker
if [[ "$MAJOR_VERSION" -ge "3" ]]; then
    CONNECT_OPTS="--bootstrap-server $(echo "${BROKER_LIST}" | cut -d ',' -f1)"
else
    CONNECT_OPTS="--zookeeper ${KAFKA_ZOOKEEPER_CONNECT}"
fi

# Expected format:
#   name:partitions:replicas:cleanup.policy
IFS="${KAFKA_CREATE_TOPICS_SEPARATOR-,}"; for topicToCreate in $KAFKA_CREATE_TOPICS; do
    echo "creating topics: $topicToCreate"
    IFS=':' read -r -a topicConfig <<< "$topicToCreate"
    config=
    if [ -n "${topicConfig[3]}" ]; then
        config="--config=cleanup.policy=${topicConfig[3]}"
    fi

    COMMAND="JMX_PORT='' ${KAFKA_HOME}/bin/kafka-topics.sh \\
		--create \\
		${CONNECT_OPTS} \\
		--topic ${topicConfig[0]} \\
		--partitions ${topicConfig[1]} \\
		--replication-factor ${topicConfig[2]} \\
		${config} \\
		${KAFKA_0_10_OPTS} &"
    eval "${COMMAND}"
done

wait
