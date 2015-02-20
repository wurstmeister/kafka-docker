kafka-docker
============

Dockerfile for [Apache Kafka](http://kafka.apache.org/)

The image is available directly from https://index.docker.io

##Pre-Requisites

- install fig [http://www.fig.sh/install.html](http://www.fig.sh/install.html)
- modify the ```KAFKA_ADVERTISED_HOST_NAME``` in ```fig.yml``` to match your docker host IP (Note: Do not use localhost or 127.0.0.1 as the host ip if you want to run multiple brokers.)
- if you want to customise any Kafka parameters, simply add them as environment variables in ```fig.yml```, e.g. in order to increase the ```message.max.bytes``` parameter set the environment to ```KAFKA_MESSAGE_MAX_BYTES: 2000000```. To turn off automatic topic creation set ```KAFKA_AUTO_CREATE_TOPICS_ENABLE: 'false'```

##Usage

Start a cluster:

- ```fig up -d ```


Add more brokers:

- ```fig scale kafka=3```

Destroy a cluster:

- ```fig stop```

##Note

The default fig.yml should be seen as a starting point. By default each broker will get a new port number and broker id on restart. Depending on your use case this might not be desirable. If you need to use specific ports and broker ids, modify the fig configuration accordingly, e.g.:

- ```fig -f fig-single-broker.yml up```
 

##Tutorial

[http://wurstmeister.github.io/kafka-docker/](http://wurstmeister.github.io/kafka-docker/)



