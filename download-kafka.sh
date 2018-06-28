#!/bin/sh -e

# shellcheck disable=SC1091
source "/usr/bin/versions.sh"

FILENAME="kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"

## Versions prior to 0.10.2.1 are not actively mirrored
echo "Downloading kafka $MAJOR_VERSION.$MINOR_VERSION"
if [[ "$MAJOR_VERSION" == "0" && "$MINOR_VERSION" -lt "11" ]]; then
	echo "Version prior to 0.10.2.1 - downloading direct"
	url="https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/${FILENAME}"
else
	url=$(curl --stderr /dev/null "https://www.apache.org/dyn/closer.cgi?path=/kafka/${KAFKA_VERSION}/${FILENAME}&as_json=1" | jq -r '"\(.preferred)\(.path_info)"')
fi

if [[ -z "$url" ]]; then
	echo "Unable to determine mirror for downloading Kafka, the service may be down"
	exit 1
fi

echo "Downloading Kafka from $url"
wget "${url}" -O "/tmp/${FILENAME}"
