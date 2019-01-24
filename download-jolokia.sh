#!/bin/sh -e

wget "http://search.maven.org/remotecontent?filepath=org/jolokia/jolokia-jvm/1.6.0/jolokia-jvm-1.6.0-agent.jar" -O "/tmp/jolokia-jvm-1.6.0-agent.jar"
mv "/tmp/jolokia-jvm-1.6.0-agent.jar" /opt/kafka/libs
chmod a+x /opt/kafka/libs/jolokia-jvm-1.6.0-agent.jar