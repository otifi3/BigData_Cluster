#!/bin/bash

# Start SSH
sudo service ssh start

# Start Hive Metastore on hive_metastore
if [[ "$HOSTNAME" == "hive_metastore" ]]; then
    # Create warehouse and temp directories only if not already created
    if ! hdfs dfs -test -d /user/hive/warehouse; then
        hdfs dfs -mkdir -p /user/hive/warehouse
        hdfs dfs -chmod -R 777 /user/hive/warehouse
        hdfs dfs -mkdir -p /tmp
        hdfs dfs -chmod -R 777 /tmp
        $HIVE_HOME/bin/schematool -initSchema -dbType postgres
    fi

    hive --service metastore &

# Start HiveServer2 on hive_server
elif [[ "$HOSTNAME" == "hive_server" ]]; then
    sleep 10
    hiveserver2 &
fi

# Keep container running
tail -f /dev/null
