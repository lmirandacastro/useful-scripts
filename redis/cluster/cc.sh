#!/bin/bash
for i in {0..5}; do
  echo -ne "700$i \t"
  redis-cli -p 700$i "$@"
done