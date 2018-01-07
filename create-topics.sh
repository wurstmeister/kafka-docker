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

check_kafka_running() {
    if [[ "$KAFKA_BROKER_ID" != "-1" ]]; then
        echo dump | nc -w 1 "$KAFKA_ZOOKEEPER_CONNECT" $KAFKA_PORT \
            | grep -F "/brokers/ids/$KAFKA_BROKER_ID"
    else
        netstat -lnt | awk '{ print $4 }' | grep ":$KAFKA_PORT"
    fi
}

while ! check_kafka_running; do
    echo "waiting for kafka to be ready"
    sleep $step;
    count=$(expr $count + $step)
    if [ $count -gt $START_TIMEOUT ]; then
        start_timeout_exceeded=true
        break
    fi
done

if $start_timeout_exceeded; then
    echo "Not able to auto-create topic (waited for $START_TIMEOUT sec)"
    exit 1
fi

IFS=','; for topicToCreate in $KAFKA_CREATE_TOPICS; do
    echo "creating topics: $topicToCreate"
    IFS=':' read -a topicConfig <<< "$topicToCreate"
    config=
    if [ -n "${topicConfig[3]}" ]; then
        config="--config cleanup.policy=${topicConfig[3]}"
    fi
    JMX_PORT='' $KAFKA_HOME/bin/kafka-topics.sh --create --zookeeper $KAFKA_ZOOKEEPER_CONNECT --replication-factor ${topicConfig[2]} --partitions ${topicConfig[1]} --topic "${topicConfig[0]}" $config --if-not-exists &
done

wait
