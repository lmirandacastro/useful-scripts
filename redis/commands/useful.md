# Lua Commands
## Load functions.lua
redis-cli -x script load < functions.lua

## Execute inline script
EVAL "return dispatcher" key_qty [KEY1 KEY2 ...] arg1 arg2 ...

## Execute with sha
EVALSHA 9b680cc95e352fc086b3c896b0dac38c14c40e80 key_qty [KEY1 KEY2 ...] arg1 arg2 ...

## Execute with name
FCALL <FUNCTION_NAME> key_qty [KEY1 KEY2 ...] arg1 arg2 ...

# Cluster

## Get keyslot
CLUSTER KEYSLOT newkey
CLUSTER KEYSLOT foo{newkey}

## Get Nodes
CLUSTER NODES

## 
