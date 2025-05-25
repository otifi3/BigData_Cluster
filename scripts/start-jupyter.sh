#!/bin/bash

# Optional: start Spark master/worker if using standalone mode
# $SPARK_HOME/sbin/start-master.sh
# $SPARK_HOME/sbin/start-worker.sh spark://localhost:7077

# Start Jupyter Notebook
jupyter notebook \
  --ip=0.0.0.0 \
  --port=8888 \
  --NotebookApp.token='' \
  --NotebookApp.password='' \
  --NotebookApp.allow_origin='*' \
  --NotebookApp.allow_remote_access=True \
  --NotebookApp.notebook_dir='/home/hadoop/notebooks' \
  --no-browser