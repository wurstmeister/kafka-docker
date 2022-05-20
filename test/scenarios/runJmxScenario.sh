#!/bin/bash

set -e -o pipefail

pushd jmx
# shellcheck disable=SC1091
source "/usr/bin/versions.sh"
# since 3.0.0 a few options has been disabled, start kafka with the propper options
if [[ "$MAJOR_VERSION" -ge "3" ]]; then
    docker-compose -f docker-compose.yml -f docker-compose-kafka3.yml up -d zookeeper kafka jmxexporter
else
    docker-compose -f docker-compose.yml -f docker-compose-kafka.yml up -d zookeeper kafka jmxexporter
fi

docker-compose run --rm test
docker-compose stop
popd
