############################
# Stage 1: hadoop-base
############################
FROM ubuntu:22.04 AS hadoop-base

ENV HADOOP_HOME=/usr/local/hadoop
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

RUN apt update && \
    apt install -y sudo openjdk-8-jdk ssh curl tar python3 python3-pip net-tools && \
    pip3 install --no-cache-dir jupyter findspark pyspark && \
    apt clean

# Create user
RUN useradd -m -s /bin/bash hadoop && \
    echo "hadoop ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Download Hadoop
WORKDIR /usr/local
ADD https://downloads.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz ./
RUN tar -xvzf hadoop-3.3.6.tar.gz && \
    mv hadoop-3.3.6 $HADOOP_HOME && \
    rm hadoop-3.3.6.tar.gz && \
    chown -R hadoop:hadoop $HADOOP_HOME

# --- START: Apache Spark installation ---
ENV SPARK_HOME=/usr/local/spark
ENV PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin

ADD https://archive.apache.org/dist/spark/spark-3.3.2/spark-3.3.2-bin-hadoop3.tgz ./
RUN tar -xzf spark-3.3.2-bin-hadoop3.tgz && \
    mv spark-3.3.2-bin-hadoop3 $SPARK_HOME && \
    rm spark-3.3.2-bin-hadoop3.tgz && \
    chown -R hadoop:hadoop $SPARK_HOME

COPY configuration/spark_configuration/spark-defaults.conf $SPARK_HOME/conf/

RUN mkdir -p /tmp/spark-events && \
    chown -R hadoop:hadoop /tmp/spark-events

# --- END: Apache Spark installation ---

# Create common folders
RUN mkdir -p $HADOOP_HOME/hdfs/namenode $HADOOP_HOME/hdfs/datanode $HADOOP_HOME/journal $HADOOP_HOME/logs && \
    chown -R hadoop:hadoop $HADOOP_HOME/hdfs $HADOOP_HOME/journal $HADOOP_HOME/logs

EXPOSE 4040 8080 18080

############################
# Stage 2: ZooKeeper node
############################
FROM hadoop-base AS zookeeper-node
WORKDIR /usr/local

ADD https://downloads.apache.org/zookeeper/zookeeper-3.9.3/apache-zookeeper-3.9.3-bin.tar.gz ./
RUN tar -xvzf apache-zookeeper-3.9.3-bin.tar.gz && \
    mv apache-zookeeper-3.9.3-bin /usr/local/zookeeper && \
    rm apache-zookeeper-3.9.3-bin.tar.gz && \
    chown -R hadoop:hadoop /usr/local/zookeeper

COPY configuration/zookeeper_configuration/zoo.cfg /usr/local/zookeeper/conf/
COPY scripts/hadoop-entrypoint.sh /home/hadoop/entrypoint.sh

RUN chmod +x /home/hadoop/entrypoint.sh && \
    chown hadoop:hadoop /home/hadoop/entrypoint.sh

USER hadoop
WORKDIR /home/hadoop
ENTRYPOINT ["/home/hadoop/entrypoint.sh"]

############################
# Stage 3: hadoop container
############################
FROM hadoop-base AS hadoop-node
COPY configuration/hadoop_configuration/*.xml $HADOOP_HOME/etc/hadoop/
COPY configuration/hadoop_configuration/workers $HADOOP_HOME/etc/hadoop/
COPY scripts/hadoop-entrypoint.sh /home/hadoop/entrypoint.sh

RUN chmod +x /home/hadoop/entrypoint.sh && \
    chown hadoop:hadoop /home/hadoop/entrypoint.sh

USER hadoop
WORKDIR /home/hadoop
ENTRYPOINT ["/home/hadoop/entrypoint.sh"]

############################
# Stage 4: Hive container
############################
FROM hadoop-base AS hive

ENV HIVE_HOME=/usr/local/hive
ENV TEZ_HOME=/usr/local/tez
ENV TEZ_CONF_DIR=$TEZ_HOME/conf
ENV HIVE_AUX_JARS_PATH=$TEZ_HOME
ENV PATH=$HIVE_HOME/bin:$TEZ_HOME/bin:$PATH

ADD https://downloads.apache.org/hive/hive-4.0.1/apache-hive-4.0.1-bin.tar.gz ./
RUN tar -xvzf apache-hive-4.0.1-bin.tar.gz && \
    mv apache-hive-4.0.1-bin /usr/local/hive && \
    rm apache-hive-4.0.1-bin.tar.gz && \
    chown -R hadoop:hadoop /usr/local/hive

ADD https://archive.apache.org/dist/tez/0.10.3/apache-tez-0.10.3-bin.tar.gz ./
RUN tar -xvzf apache-tez-0.10.3-bin.tar.gz && \
    mv apache-tez-0.10.3-bin /usr/local/tez && \
    rm apache-tez-0.10.3-bin.tar.gz && \
    chown -R hadoop:hadoop /usr/local/tez

ADD https://jdbc.postgresql.org/download/postgresql-42.2.5.jar ./
RUN mv postgresql-42.2.5.jar $HIVE_HOME/lib/

COPY configuration/hive_configuration/hive-site.xml $HIVE_HOME/conf/
COPY configuration/hive_configuration/tez-site.xml $TEZ_HOME/conf/
COPY scripts/hive-entrypoint.sh /home/hadoop/entrypoint.sh

RUN chmod +x /home/hadoop/entrypoint.sh && \
    chown hadoop:hadoop /home/hadoop/entrypoint.sh

USER hadoop
WORKDIR /home/hadoop
EXPOSE 10000
ENTRYPOINT ["/home/hadoop/entrypoint.sh"]

############################
# Stage 5: HBase container
############################
FROM hadoop-node AS hbase

ENV HBASE_HOME=/usr/local/hbase
ENV PATH=$HBASE_HOME/bin:$PATH

USER root
ADD https://archive.apache.org/dist/hbase/2.4.9/hbase-2.4.9-bin.tar.gz /usr/local/
RUN tar -xvzf /usr/local/hbase-2.4.9-bin.tar.gz -C /usr/local && \
    mv /usr/local/hbase-2.4.9 /usr/local/hbase && \
    rm /usr/local/hbase-2.4.9-bin.tar.gz && \
    chown -R hadoop:hadoop /usr/local/hbase

USER hadoop
COPY configuration/hbase_configuration/hbase-site.xml $HBASE_HOME/conf/hbase-site.xml
COPY scripts/hbase-entrypoint.sh /home/hadoop/entrypoint.sh

RUN cp $HADOOP_HOME/share/hadoop/common/lib/* $HBASE_HOME/lib/ && \
    chmod +x /home/hadoop/entrypoint.sh && \
    chown hadoop:hadoop /home/hadoop/entrypoint.sh

WORKDIR /home/hadoop
EXPOSE 16000 16010 16020 2181
ENTRYPOINT ["/home/hadoop/entrypoint.sh"]
