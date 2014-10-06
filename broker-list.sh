#!/bin/bash

CONTAINER=`docker ps | grep 9092 | head -n 1 | awk  '{print $1}'`
docker port $CONTAINER 9092 | sed -r "s/(0.0.0.0):(.*)/$HOST_IP:\2/g"
