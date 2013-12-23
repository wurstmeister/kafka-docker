#!/bin/bash
docker run -link zookeeper:zk -i -t wurstmeister/kafka /bin/bash

