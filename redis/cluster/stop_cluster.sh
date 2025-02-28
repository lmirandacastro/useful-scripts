#!/bin/bash

hosts=$1
if [ -z "$1" ]; then
  hosts=6
fi
start_port=$2
if [ -z "$start_port" ]; then
  start_port=7000
fi

for ((i=$start_port;i<$((start_port+hosts));i++))
do
  cd $i
  redis-cli -p $i shutdown
  rm dump.rdb
  rm nodes.conf
  rm -rf appendonlydir
  rm redis.conf
  cd ..
  rm -rf $i
done
