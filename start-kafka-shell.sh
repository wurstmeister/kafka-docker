#!/bin/bash
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock --link kafkadocker_zookeeper_1:zk -e HOST_IP=$1 -i -t wurstmeister/kafka:latest /bin/bash
