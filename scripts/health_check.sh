#!/bin/bash

rm_active=$(yarn rmadmin -getAllServiceState | grep -i 'active' | wc -l)

nn_active=$(hdfs haadmin -getAllServiceState | grep -i 'active' | wc -l)

if [ "$rm_active" -gt 0 ] || [ "$nn_active" -gt 0 ]; then
  exit 0
else
  exit 1
fi


