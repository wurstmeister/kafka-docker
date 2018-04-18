#!/bin/sh -e
KAFKA_VERSION=1.1.0
SCALA_VERSION=2.12
path="kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"
url=$(curl --stderr /dev/null "https://www.apache.org/dyn/closer.cgi?path=/${path}&as_json=1" | jq -r '"\(.preferred)\(.path_info)"')

if [[ -z "$url" ]]; then
	echo "Unable to determine mirror for downloading Kafka, the service may be down"
	exit 1
fi

wget -q "${url}" -O "/tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"
