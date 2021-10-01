FROM i.scrapinghub.com/kafka/rel-1.1.1:64b1a57

ARG kafka_version=1.1.1
ARG scala_version=2.12
ARG glibc_version=2.27-r0
ARG kafka_connect_bigquery=2.1.7

MAINTAINER wurstmeister

ENV KAFKA_VERSION=$kafka_version \
    SCALA_VERSION=$scala_version \
    KAFKA_HOME=/opt/kafka \
    GLIBC_VERSION=$glibc_version


VOLUME ["/kafka"]

RUN wget https://d1i4a15mxbxib1.cloudfront.net/api/plugins/wepay/kafka-connect-bigquery/versions/${kafka_connect_bigquery}/wepay-kafka-connect-bigquery-${kafka_connect_bigquery}.zip \
 && unzip wepay-kafka-connect-bigquery-${kafka_connect_bigquery}.zip \
 && mv wepay-kafka-connect-bigquery-${kafka_connect_bigquery}/lib/* /opt/kafka_2.12-1.1.1/libs/ \
 && rm -v *.zip

#RUN mkdir /opt/connectors && cd /opt/connectors \
# && wget https://d1i4a15mxbxib1.cloudfront.net/api/plugins/wepay/kafka-connect-bigquery/versions/${kafka_connect_bigquery}/wepay-kafka-connect-bigquery-${kafka_connect_bigquery}.zip \
# && unzip wepay-kafka-connect-bigquery-${kafka_connect_bigquery}.zip \
# && mv wepay-kafka-connect-bigquery-${kafka_connect_bigquery}/lib/* . \
# && rm -fr wepay-kafka-connect-bigquery-${kafka_connect_bigquery} \
# && rm -v *.zip

# Use "exec" form so that it runs as PID 1 (useful for graceful shutdown)
CMD ["start-kafka.sh"]
