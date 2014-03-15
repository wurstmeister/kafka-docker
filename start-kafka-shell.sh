#!/bin/bash
docker run -link zookeeper:zk -i -t wurstmeister/kafka:0.8.1 /bin/bash

