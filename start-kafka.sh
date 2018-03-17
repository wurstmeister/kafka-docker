#!/bin/bash -e

if [[ -z "$KAFKA_PORT" ]]; then
    export KAFKA_PORT=9092
fi

create-topics.sh &
unset KAFKA_CREATE_TOPICS

# DEPRECATED: but maintained for compatibility with older brokers pre 0.9.0 (https://issues.apache.org/jira/browse/KAFKA-1809)
if [[ -z "$KAFKA_ADVERTISED_PORT" && \
  -z "$KAFKA_LISTENERS" && \
  -z "$KAFKA_ADVERTISED_LISTENERS" && \
  -S /var/run/docker.sock ]]; then
    KAFKA_ADVERTISED_PORT=$(docker port "$(hostname)" $KAFKA_PORT | sed -r 's/.*:(.*)/\1/g')
    export KAFKA_ADVERTISED_PORT
fi

if [[ -z "$KAFKA_BROKER_ID" ]]; then
    if [[ -n "$BROKER_ID_COMMAND" ]]; then
        KAFKA_BROKER_ID=$(eval "$BROKER_ID_COMMAND")
        export KAFKA_BROKER_ID
    else
        # By default auto allocate broker ID
        export KAFKA_BROKER_ID=-1
    fi
fi

if [[ -z "$KAFKA_LOG_DIRS" ]]; then
    export KAFKA_LOG_DIRS="/kafka/kafka-logs-$HOSTNAME"
fi

# DEPRECATED(sscaling): Remove and document
if [[ -z "$KAFKA_ZOOKEEPER_CONNECT" ]]; then
    KAFKA_ZOOKEEPER_CONNECT=$(env | grep 'ZK.*PORT_2181_TCP=' | sed -e 's|.*tcp://||' | paste -sd ,)
    export KAFKA_ZOOKEEPER_CONNECT
fi

if [[ -n "$KAFKA_HEAP_OPTS" ]]; then
    sed -r -i 's/(export KAFKA_HEAP_OPTS)="(.*)"/\1="'"$KAFKA_HEAP_OPTS"'"/g' "$KAFKA_HOME/bin/kafka-server-start.sh"
    unset KAFKA_HEAP_OPTS
fi

if [[ -z "$KAFKA_ADVERTISED_HOST_NAME" && -n "$HOSTNAME_COMMAND" ]]; then
    KAFKA_ADVERTISED_HOST_NAME=$(eval "$HOSTNAME_COMMAND")
    export KAFKA_ADVERTISED_HOST_NAME

    # Replace any occurences of _{HOSTNAME_COMMAND} with the value
    for VAR in $(env); do
      if [[ $VAR =~ ^KAFKA_ && "$VAR" =~ "_{HOSTNAME_COMMAND}" ]]; then
        # shellcheck disable=SC2163
        export "${VAR//_\{HOSTNAME_COMMAND\}/$KAFKA_ADVERTISED_HOST_NAME}"
      fi
    done
fi


# For a valid config, we need to specify atleast the 'listeners' config
if [[ -z "$KAFKA_LISTENERS" ]]; then
  export KAFKA_LISTENERS="PLAINTEXT://${KAFKA_ADVERTISED_HOST_NAME-}:${KAFKA_ADVERTISED_PORT-9092}"
fi

if [[ -n "$RACK_COMMAND" && -z "$KAFKA_BROKER_RACK" ]]; then
    KAFKA_BROKER_RACK=$(eval "$RACK_COMMAND")
    export KAFKA_BROKER_RACK
fi

#Issue newline to config file in case there is not one already
echo "" >> "$KAFKA_HOME/config/server.properties"

unset KAFKA_ADVERTISED_PORT
unset KAFKA_ADVERTISED_HOST_NAME

for VAR in $(env)
do
  if [[ $VAR =~ ^KAFKA_ && ! $VAR =~ ^KAFKA_HOME ]]; then
    kafka_name=$(echo "$VAR" | sed -r 's/KAFKA_(.*)=.*/\1/g' | tr '[:upper:]' '[:lower:]' | tr _ .)
    env_var=$(echo "$VAR" | sed -r 's/(.*)=.*/\1/g')
    if grep -E -q '(^|^#)'"$kafka_name=" "$KAFKA_HOME/config/server.properties"; then
        sed -r -i 's@(^|^#)('"$kafka_name"')=(.*)@\2='"${!env_var}"'@g' "$KAFKA_HOME/config/server.properties" #note that no config values may contain an '@' char
    else
        echo "$kafka_name=${!env_var}" >> "$KAFKA_HOME/config/server.properties"
    fi
  fi

  if [[ $VAR =~ ^LOG4J_ ]]; then
    log4j_name=$(echo "$VAR" | sed -r 's/(LOG4J_.*)=.*/\1/g' | tr '[:upper:]' '[:lower:]' | tr _ .)
    log4j_env=$(echo "$VAR" | sed -r 's/(.*)=.*/\1/g')
    if grep -E -q '(^|^#)'"$log4j_name=" "$KAFKA_HOME/config/log4j.properties"; then
        sed -r -i 's@(^|^#)('"$log4j_name"')=(.*)@\2='"${!log4j_env}"'@g' "$KAFKA_HOME/config/log4j.properties" #note that no config values may contain an '@' char
    else
        echo "$log4j_name=${!log4j_env}" >> "$KAFKA_HOME/config/log4j.properties"
    fi
  fi
done

if [[ -n "$CUSTOM_INIT_SCRIPT" ]] ; then
  eval "$CUSTOM_INIT_SCRIPT"
fi

exec "$KAFKA_HOME/bin/kafka-server-start.sh" "$KAFKA_HOME/config/server.properties"
