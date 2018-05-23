#!/bin/bash

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

if [[ -n "$KAFKA_CREATE_TOPICS" ]]; then
    # Expected format:
    # name:partitions:replicas:cleanup.policy
        IFS="${KAFKA_CREATE_TOPICS_SEPARATOR-,}"; for topicToCreate in $KAFKA_CREATE_TOPICS; do
        echo "creating topics: $topicToCreate"
        IFS=':' read -r -a topicConfig <<< "$topicToCreate"
        config=
        if [ -n "${topicConfig[3]}" ]; then
            config="--config=cleanup.policy=${topicConfig[3]}"
        fi
        COMMAND="JMX_PORT='' ${KAFKA_HOME}/bin/kafka-topics.sh \\
    		--create \\
		    --zookeeper ${KAFKA_ZOOKEEPER_CONNECT} \\
    		--topic ${topicConfig[0]} \\
		    --partitions ${topicConfig[1]} \\
    		--replication-factor ${topicConfig[2]} \\
		    ${config} \\
    		--if-not-exists &"
        eval "${COMMAND}"
    done
fi

wait

if [[ -n "$KAFKA_CONFIGS" ]]; then
    # Expected format:
    # type:name:add|delete:a=b c=d
        IFS="${KAFKA_CONFIG_SEPARATOR-,}"; for configToChange in $KAFKA_CONFIGS; do
        echo "changing config: $configToChange"
        IFS=':' read -r -a entityConfig <<< "$configToChange"
        config="${entityConfig[3]}"
        COMMAND="JMX_PORT='' ${KAFKA_HOME}/bin/kafka-configs.sh \\
		    --zookeeper ${KAFKA_ZOOKEEPER_CONNECT} \\
    		--entity-type ${entityConfig[0]} \\
    		--entity-name ${entityConfig[1]} \\
        --alter \\
        --${entityConfig[2]}-config ${config// /,} &"
        eval "${COMMAND}"
    done
fi

wait
