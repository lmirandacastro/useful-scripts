#!/bin/bash

hosts=$1
if [ -z "$1" ]; then
  hosts=6
fi
start_port=$2
if [ -z "$start_port" ]; then
  start_port=7000
fi
command="redis-cli --cluster create "
for ((i=$start_port;i<$((start_port+hosts));i++))
do
  echo $i
  mkdir -p $i
  echo "port $i
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 5000
appendonly yes
daemonize yes" > $i/redis.conf
  command="$command 127.0.0.1:$i "
  cd $i
  redis-server ./redis.conf
  cd ..
done
command="$command --cluster-replicas 1"
echo $command
$command
