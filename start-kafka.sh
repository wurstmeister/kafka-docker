#!/bin/bash

date

if [[ -z "$KAFKA_ADVERTISED_PORT" ]]; then
    export KAFKA_ADVERTISED_PORT=$(docker port `hostname` 9092 | sed -r "s/.*:(.*)/\1/g")
fi
if [[ -z "$KAFKA_BROKER_ID" ]]; then
    export KAFKA_BROKER_ID=$(docker inspect `hostname` | jq --raw-output '.[0] | .Name' | awk -F_ '{print $3}')
	echo UsedDockerHostNameToSetKafkaBrokerIdTo $KAFKA_BROKER_ID
fi
if [[ -z "$KAFKA_BROKER_ID" ]]; then
    uniqueNumber=$(date +%s%3N)
	((uniqueNumber=uniqueNumber-1447000000000))
	((uniqueNumber=uniqueNumber+$RANDOM))
    export KAFKA_BROKER_ID=$uniqueNumber
	echo UsedTimePlusRandomNumberToSetKafkaBrokerIdTo $KAFKA_BROKER_ID
fi
if [[ -z "$KAFKA_LOG_DIRS" ]]; then
    export KAFKA_LOG_DIRS="/kafka/kafka-logs-$KAFKA_BROKER_ID"
fi
if [[ -z "$KAFKA_ZOOKEEPER_CONNECT" ]]; then
    export KAFKA_ZOOKEEPER_CONNECT=$(env | grep ZK.*PORT_2181_TCP= | sed -e 's|.*tcp://||' | paste -sd ,)
fi
if [[ -n "$KAFKA_HEAP_OPTS" ]]; then
    sed -r -i "s/(export KAFKA_HEAP_OPTS)=\"(.*)\"/\1=\"$KAFKA_HEAP_OPTS\"/g" $KAFKA_HOME/bin/kafka-server-start.sh
    unset KAFKA_HEAP_OPTS
fi
if [[ -n "$ADVERTISED_HOST_NAME_SCRIPT" ]]; then
	echo AboutToCalculateHostNameUsing $ADVERTISED_HOST_NAME_SCRIPT
    export KAFKA_ADVERTISED_HOST_NAME=$(eval $ADVERTISED_HOST_NAME_SCRIPT)
	echo UsedScriptToCalculatedHostNameAs $KAFKA_ADVERTISED_HOST_NAME
fi
if [[ -z "$KAFKA_ADVERTISED_HOST_NAME" ]]; then
    export KAFKA_ADVERTISED_HOST_NAME=$(route -n | awk '/UG[ \t]/{print $2}')
	echo UsedRouteToCalculatedHostNameAs $KAFKA_ADVERTISED_HOST_NAME
fi

for VAR in `env`
do
  if [[ $VAR =~ ^KAFKA_ && ! $VAR =~ ^KAFKA_HOME ]]; then
    kafka_name=`echo "$VAR" | sed -r "s/KAFKA_(.*)=.*/\1/g" | tr '[:upper:]' '[:lower:]' | tr _ .`
    env_var=`echo "$VAR" | sed -r "s/(.*)=.*/\1/g"`
    if egrep -q "(^|^#)$kafka_name=" $KAFKA_HOME/config/server.properties; then
        sed -r -i "s@(^|^#)($kafka_name)=(.*)@\2=${!env_var}@g" $KAFKA_HOME/config/server.properties #note that no config values may contain an '@' char
    else
        echo "$kafka_name=${!env_var}" >> $KAFKA_HOME/config/server.properties
    fi
  fi
done

date

if [[ -n "$USE_SUPERVISOR" ]]; then
    echo UsingSupervisor
    supervisord -n
else
    echo AboutToStartKafkaServer

    $KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties &
    KAFKA_SERVER_PID=$!

    date
    echo JustStartedProcessId $KAFKA_SERVER_PID

    while netstat -lnt | awk '$4 ~ /:9092$/ {exit 1}'; do sleep 1; done

    date
    echo DoneWaitingForNetworkResponse

    if [[ -n $KAFKA_CREATE_TOPICS ]]; then
        IFS=','; for topicToCreate in $KAFKA_CREATE_TOPICS; do
            IFS=':' read -a topicConfig <<< "$topicToCreate"
            $KAFKA_HOME/bin/kafka-topics.sh --create --zookeeper $KAFKA_ZOOKEEPER_CONNECT --replication-factor ${topicConfig[2]} --partition ${topicConfig[1]} --topic "${topicConfig[0]}"
        done
        
        date
        echo DoneCreatingTopics $KAFKA_CREATE_TOPICS
    fi
    
    wait $KAFKA_SERVER_PID
fi


