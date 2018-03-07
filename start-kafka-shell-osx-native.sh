#!/bin/bash
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -e HOST_IP=$1 -e ZK=$2 --net=$3 -i -t wurstmeister/kafka /bin/bash
