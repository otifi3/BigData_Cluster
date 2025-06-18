# 🏗️ High-Availability Big Data Cluster (HDFS + HBase + Hive + Spark)

This project sets up a **highly available, production-grade Hadoop ecosystem** using **Docker and Docker Compose**. It integrates:

- **HDFS with NameNode HA**
- **HBase with HMaster failover and RegionServers**
- **Hive with ACID support and PostgreSQL-backed Metastore**
- **Apache Spark as a unified execution engine**
- **Spark History Server** for accessing completed job UIs

> All services run in isolated containers, orchestrated via Docker Compose for local development, testing, or lightweight production environments. Designed to simulate a fault-tolerant, scalable big data architecture for analytics, batch, and real-time workloads.

---

## ⚙️ Cluster Topology

| Component           | Quantity | HA Enabled | Description                                            |
|--------------------|----------|------------|--------------------------------------------------------|
| NameNode           | 2        | ✅          | Active/Standby with automatic failover                 |
| Zookeeper          | 3        | ✅          | Quorum for failover coordination                       |
| JournalNode        | 3        | ✅          | Shared edit logs for HDFS HA                           |
| DataNode           | 2        | N/A        | Block storage and replication                          |
| HMaster            | 2        | ✅          | Master failover in HBase                               |
| RegionServer       | 2        | N/A        | HBase region handling                                  |
| HiveServer2        | 1        | ✅          | Serves Hive queries via JDBC/Beeline                   |
| Metastore          | 1        | ✅          | Backed by PostgreSQL, supports ACID                    |
| PostgreSQL         | 1        | ✅          | Hive Metastore backend                                 |
| Apache Spark       | 1+       | ✅          | Processing engine for Hive, HDFS, and HBase            |
| Spark History Srv  | 1        | N/A        | UI for completed Spark jobs                            |

All components are containerized and coordinated using Docker Compose for simplicity, repeatability, and portability.

---

## 🧱 Components and Architecture

```text
                               +----------------------+
                               |     Clients / UI     |
                               +----------+-----------+
                                          |
+-------------------+       +-----------------v------------------+
|  HiveServer2 + Tez| <---> |     Hive Metastore (PostgreSQL)    |
+-------------------+       +------------------------------------+
          |                                   |
          v                                   v
+-------------------+       +-----------------+       +----------------+
|     Apache Spark  | <---> |      HDFS       | <---> |     HBase      |
|                   |       | (HA NameNodes)  |       | (HA HMasters)  |
+-------------------+       +-----------------+       +----------------+
                                          |                 |
                                 +----------------+   +----------------+
                                 |   DataNodes    |   | RegionServers  |
                                 +----------------+   +----------------+
                                          |
                               +------------------------+
                               |   Zookeeper + JN Quorum|
                               +------------------------+
                                          |
                               +------------------------+
                               |   Spark History Server |
                               +------------------------+
```

---

## 🚀 Key Features

* **🟢 HDFS HA**: NameNode high availability via Zookeeper + JournalNodes
* **📂 HBase HA**: Master failover with RegionServers managing data partitions
* **🧠 Hive on Tez**: Fast SQL queries with ACID transactional table support
* **🐘 PostgreSQL Metastore**: Reliable metadata storage for Hive
* **⚡ Spark Engine**: Distributed computation across HDFS, Hive, and HBase
* **📆 Spark History Server**: UI for tracking completed Spark jobs
* **📦 Storage**: Supports ORC, Parquet, Avro, and plain text formats
* **🐳 Dockerized**: Entire stack deployed in Docker containers via Docker Compose
* **💪 Durable & Scalable**: Designed for production workloads and real-time jobs

---

## 🔧 Technologies Used

| Layer        | Tech Stack                                |
| ------------ | ----------------------------------------- |
| Storage      | HDFS (HA), HBase (HA)                     |
| Query Engine | Hive (Tez execution engine), Apache Spark |
| Metadata     | Hive Metastore backed by PostgreSQL       |
| Coordination | Apache Zookeeper, JournalNodes            |
| Transport    | RPC, HTTP, JDBC                           |
| Format       | ORC, Parquet, Avro, CSV                   |
| Logging      | Spark History Server (logs to HDFS)       |
| Container    | Docker, Docker Compose                    |
| OS Base      | Linux (Ubuntu/CentOS compatible)          |

---

## 📆 Setup Instructions

> ✅ **All components are pre-configured with Dockerfiles and docker-compose.yml files. No manual provisioning needed.**

1. **Clone the repository**

   ```bash
   git clone https://github.com/otifi3/BigData_Cluster.git
   cd BigData_Cluster
   ```

2. **Create Spark log directory in HDFS**

   ```bash
   docker exec -it master1 bash
   hdfs dfs -mkdir -p /spark-logs
   hdfs dfs -chmod -R 1777 /spark-logs
   ```

3. **Start the cluster**

   ```bash
   docker-compose up -d
   ```

4. **Access Spark History UI**

   Open [http://localhost:18080](http://localhost:18080) in your browser
---

## 🧪 Supported Use Cases

* ACID-compliant Hive table creation and inserts
* Spark SQL queries across Hive tables and HBase datasets
* Scalable NoSQL read/write workloads via HBase API
* Batch ingestion pipelines using Spark jobs
* Ad-hoc analytical queries using Hive or Beeline
* Viewing and managing completed Spark jobs via History Server

---

## 📁 File Formats & Table Types

| Format   | Optimized For         | ACID Support | Hive Compatible |
| -------- | --------------------- | ------------ | --------------- |
| ORC      | Read performance, Tez | ✅            | ✅               |
| Parquet  | Columnar analytics    | ✅            | ✅               |
| Avro     | Row-based streaming   | ❌            | ✅               |
| TextFile | Debugging, CSV logs   | ❌            | ✅               |

---

## 📙 References

* [Hadoop\_Cluster](https://github.com/otifi3/hadoop_cluster)
* [HBase\_Cluster](https://github.com/otifi3/hbase_cluster)
* [Hive\_Cluster](https://github.com/otifi3/hive_cluster)

---

## 😋 Contact
For setup questions or improvements, reach out via GitHub: [@otifi3](https://github.com/otifi3)
