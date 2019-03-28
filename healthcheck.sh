#! /bin/bash

r=`$KAFKA_HOME/bin/zookeeper-shell.sh zookeeper:2181 <<< "ls /brokers/ids" | tail -1 | jq '.[]'`   
ids=( $r )                                                                                         
function contains() {
     local n=$#
     local value=${!n}
     for ((i=1;i < $#;i++)) {
         if [ "${!i}" == "${value}" ]; then
             echo "y"
             return 0
         fi
     }
     echo "n"
     return 1
}

LOG_DIR=$(awk -F= -v x="log.dirs" '$1==x{print $2}' /opt/kafka/config/server.properties)
x=`cat ${LOG_DIR}/meta.properties | awk 'BEGIN{FS="="}/^broker.id=/{print $2}'`
if [ $(contains "${ids[@]}" "$x") == "y" ]; then echo "ok"; exit 0; else echo "doh"; exit 1; fi
