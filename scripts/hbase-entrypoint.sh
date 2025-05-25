#!/bin/bash

# Start SSH
sudo service ssh start

# Start HBase Master if hostname is hmaster1 or hmaster2
if [[ "$HOSTNAME" == hmaster* ]]; then
    if ! hdfs dfs -test -d /hbase; then
        hdfs dfs -mkdir -p /hbase
        hdfs dfs -chown hadoop:hadoop /hbase
    fi
    $HBASE_HOME/bin/hbase-daemon.sh start master

# Start HBase RegionServer if hostname is regionserver*
elif [[ "$HOSTNAME" == regionserver* ]]; then
    hdfs --daemon start datanode
    yarn --daemon start nodemanager
    $HBASE_HOME/bin/hbase-daemon.sh start regionserver
fi

# Keep container running
tail -f /dev/null