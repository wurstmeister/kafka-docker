#!/bin/bash

CONTAINERS=$(docker inspect -f '{{ .NetworkSettings.Networks.test_default.IPAddress  }}' test_kafka_1 test_kafka_2 | awk '{printf "%s:9092\n", $1}' | tr '\n' ',')
echo ${CONTAINERS%,}
