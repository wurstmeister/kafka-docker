#!/bin/bash

set -e -o pipefail

pushd jmx
docker-compose up -d zookeeper kafka jmxexporter
docker-compose run --rm test
docker-compose stop
popd
