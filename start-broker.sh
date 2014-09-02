#!/usr/bin/env bash

set -eu

if [ "$#" -ne 3 ]; then
  echo "USAGE: $0 broker-id broker-port hostname"
  echo
  echo '[broker-id] an integer that works as the broker-id.'
  echo '[broker-port] the port the broker listens to.'
  echo '[hostname] a hostname or ip address.  This value needs to be routable'
  echo 'for other Docker images to talk to the Broker.  This can be achieved by'
  echo 'giving a routable ip address, or linking the containers.'
  exit 1
fi

ID=$1
PORT=$2
HOST_IP=$3


# My apologies for not including $ in the regex.  This is because we want this
# to be able to run on a Mac.
ZOOKEEPER_DOCKER_REGEX='jplock/zookeeper.*zookeeper'
if [ ! -z "$(docker ps | grep ${ZOOKEEPER_DOCKER_REGEX})" ]; then
  echo 'Zookeeper is running.'
elif [ ! -z "$(docker ps -a | grep ${ZOOKEEPER_DOCKER_REGEX})" ]; then
  echo 'Zookeeper is restarting.'
  docker restart zookeeper
else
  echo 'Zookeeper is starting.'
  docker run -p 49181:2181  -h zookeeper --name zookeeper -d jplock/zookeeper
fi

docker run -p $PORT:$PORT --link zookeeper:zk -e BROKER_ID=$ID -e HOST_IP=$HOST_IP -e PORT=$PORT -d wurstmeister/kafka:0.8.1

