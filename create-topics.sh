#!/bin/bash

if [[ -n $KAFKA_CREATE_TOPICS ]]; then
  cnt=0
  IFS=','; for topicToCreate in $KAFKA_CREATE_TOPICS; do
    topic[cnt]=$topicToCreate
    let "cnt=cnt+1"
  done
fi

if [[ -z "$START_TIMEOUT" ]]; then
    START_TIMEOUT=600
fi

start_timeout_exceeded=false
count=0
step=10


check_kafka_running() {
  [[ $(kafkacat -L -b 127.0.0.1:$KAFKA_PORT -J) ]]
}

broker_count() {
  echo $(kafkacat -L -b 127.0.0.1:$KAFKA_PORT  -J  | jq '.brokers| length')
}

partition_count() {
  result=$(kafkacat -L -b 127.0.0.1:$KAFKA_PORT  -J |  jq --arg topic "$1" '.topics | .[] |  select(.topic == $topic).partitions | length')
  if [[ $result ]] ; then
    echo $result
  else
    echo 0
  fi
}

have_topics_to_create() {
  [[ ${#topic[@]} -gt "0" ]]
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

while have_topics_to_create; do
    echo "creating topics ... "
    for topicToCreate in ${topic[@]}; do
        echo "creating topics: $topicToCreate"
        IFS=':' read -a topicConfig <<< "$topicToCreate"
        if [ $(broker_count) -ge "${topicConfig[2]}" ] ; then
          if [ $(partition_count ${topicConfig[0]}) -gt "0"  ] ; then
            echo "Topic ${topicConfig[0]} already exists";
          else
            if [ ${topicConfig[3]} ]; then
              JMX_PORT='' $KAFKA_HOME/bin/kafka-topics.sh --create --zookeeper $KAFKA_ZOOKEEPER_CONNECT --replication-factor ${topicConfig[2]} --partition ${topicConfig[1]} --topic "${topicConfig[0]}" --config cleanup.policy="${topicConfig[3]}"
            else
              JMX_PORT='' $KAFKA_HOME/bin/kafka-topics.sh --create --zookeeper $KAFKA_ZOOKEEPER_CONNECT --replication-factor ${topicConfig[2]} --partition ${topicConfig[1]} --topic "${topicConfig[0]}"
            fi
          fi
          topic=("${topic[@]:1}")
        else
          echo "Not enough brokers available to support replication factor ${topicConfig[2]} for topic ${topicConfig[0]}"
        fi
    done
    sleep $step;
    count=$(expr $count + $step)
    if [ $count -gt $START_TIMEOUT ]; then
        start_timeout_exceeded=true
        break
    fi
done
echo "Topic creation done"
