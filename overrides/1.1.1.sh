#!/bin/bash -e

echo "[Configuring] Enabling 'plugins' (disabled)"
#sed -i -e 's|^#plugin.path=|plugin.path=/opt/connectors|g' \
#	"$KAFKA_HOME/config/connect-standalone.properties" \
#	"$KAFKA_HOME/config/connect-distributed.properties"
#
#sed -i -e 's|^#rest.port=8083|rest.port=8083|g' \
#	"$KAFKA_HOME/config/connect-distributed.properties"
