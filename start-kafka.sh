#!/bin/bash -e

if [[ -z "$KAFKA_ZOOKEEPER_CONNECT" ]]; then
    echo "ERROR: missing mandatory config: KAFKA_ZOOKEEPER_CONNECT"
    exit 1
fi

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

if [[ -n "$KAFKA_HEAP_OPTS" ]]; then
    sed -r -i 's/(export KAFKA_HEAP_OPTS)="(.*)"/\1="'"$KAFKA_HEAP_OPTS"'"/g' "$KAFKA_HOME/bin/kafka-server-start.sh"
    unset KAFKA_HEAP_OPTS
fi

if [[ -n "$HOSTNAME_COMMAND" ]]; then
    HOSTNAME_VALUE=$(eval "$HOSTNAME_COMMAND")

    # Replace any occurences of _{HOSTNAME_COMMAND} with the value
    for VAR in $(env); do
        if [[ $VAR =~ ^KAFKA_ && "$VAR" =~ "_{HOSTNAME_COMMAND}" ]]; then
            eval "export ${VAR//_\{HOSTNAME_COMMAND\}/$HOSTNAME_VALUE}"
        fi
    done
fi

if [[ -n "$PORT_COMMAND" ]]; then
    PORT_VALUE=$(eval "$PORT_COMMAND")
    # Replace any occurences of _{PORT_COMMAND} with the value
    for VAR in $(env); do
        if [[ $VAR =~ ^KAFKA_ && "$VAR" =~ "_{PORT_COMMAND}" ]]; then
	    eval "export ${VAR//_\{PORT_COMMAND\}/$PORT_VALUE}"
        fi
    done
fi

if [[ -n "$RACK_COMMAND" && -z "$KAFKA_BROKER_RACK" ]]; then
    KAFKA_BROKER_RACK=$(eval "$RACK_COMMAND")
    export KAFKA_BROKER_RACK
fi

# Try and configure minimal settings or exit with error if there isn't enough information
if [[ -z "$KAFKA_ADVERTISED_HOST_NAME$KAFKA_LISTENERS" ]]; then
    if [[ -n "$KAFKA_ADVERTISED_LISTENERS" ]]; then
        echo "ERROR: Missing environment variable KAFKA_LISTENERS. Must be specified when using KAFKA_ADVERTISED_LISTENERS"
        exit 1
    elif [[ -z "$HOSTNAME_VALUE" ]]; then
        echo "ERROR: No listener or advertised hostname configuration provided in environment."
        echo "       Please define KAFKA_LISTENERS / (deprecated) KAFKA_ADVERTISED_HOST_NAME"
        exit 1
    fi

    # Maintain existing behaviour
    # If HOSTNAME_COMMAND is provided, set that to the advertised.host.name value if listeners are not defined.
    export KAFKA_ADVERTISED_HOST_NAME="$HOSTNAME_VALUE"
fi

#Issue newline to config file in case there is not one already
echo "" >> "$KAFKA_HOME/config/server.properties"

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
