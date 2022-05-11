#!/bin/bash

CONTAINERS=$(docker ps | grep 9092 | awk '{print $1}')
# We are just interested in ipv4 addresses, so ignore ipv6 addresses
BROKERS=$(for CONTAINER in ${CONTAINERS}; do docker port "$CONTAINER" 9092 | grep '0.0.0.0' | sed -e "s/0.0.0.0:/$HOST_IP:/g"; done)
echo "${BROKERS//$'\n'/,}"
