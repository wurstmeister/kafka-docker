#!/bin/sh -e

mirror=$(curl --stderr /dev/null 'https://www.apache.org/dyn/closer.cgi?as_json=1' | jq -r '.preferred')

if [[ -z "$mirror" ]]; then
	echo "Unable to determine mirror for downloading Kafka, the service may be down"
	exit 1
fi

url="${mirror}kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"
wget -q "${url}" -O "/tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"
