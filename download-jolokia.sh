#!/bin/sh -e

wget "http://search.maven.org/remotecontent?filepath=org/jolokia/jolokia-jvm/${JOLOKIA_VERSION}/jolokia-jvm-${JOLOKIA_VERSION}-agent.jar" -O "/tmp/jolokia-jvm-${JOLOKIA_VERSION}-agent.jar"
mv "/tmp/jolokia-jvm-${JOLOKIA_VERSION}-agent.jar" /opt/kafka/libs
chmod a+x /opt/kafka/libs/jolokia-jvm-${JOLOKIA_VERSION}-agent.jar