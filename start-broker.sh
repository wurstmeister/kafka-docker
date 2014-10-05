#!/bin/bash
ZOOKEEPER=`docker ps -a | awk '{print $NF}'  | grep "zookeeper$"`
ZOOKEEPER_RUNNING=$?
if [ $ZOOKEEPER_RUNNING -eq 0 ] ;
then
    echo "Zookeeper is already running"
else
    echo "Starting Zookeeper"
    docker run -p 49181:2181  -h zookeeper --name zookeeper -d jplock/zookeeper
fi

HOST_IP=$1

docker run -v /var/run/docker.sock:/var/run/docker.sock -p 9092 --link zookeeper:zk -e KAFKA_ADVERTISED_HOST_NAME=$HOST_IP -d wurstmeister/kafka

