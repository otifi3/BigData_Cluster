#!/bin/bash

# Start SSH
sudo service ssh start

if [[ "$HOSTNAME" == master* ]]; then
    if [[ "$HOSTNAME" == "master1" ]]; then
        if [[ ! -d "/usr/local/hadoop/hdfs/namenode/current" ]]; then
            hdfs namenode -format -clusterId hadoop-cluster && hdfs zkfc -formatZK
        fi
        hdfs --daemon start namenode
        hdfs --daemon start zkfc
        yarn --daemon start resourcemanager
    else  # m2 or any other standby
        if [[ ! -d "/usr/local/hadoop/hdfs/namenode/current" ]]; then
            sleep 5
            hdfs namenode -bootstrapStandby
        fi
        hdfs --daemon start namenode
        hdfs --daemon start zkfc
        yarn --daemon start resourcemanager
    fi

elif [[ "$HOSTNAME" == worker* ]]; then
    hdfs --daemon start datanode
    yarn --daemon start nodemanager
    /home/hadoop/scripts/start-jupyter.sh &

fi

# Keep container running
tail -f /dev/null
