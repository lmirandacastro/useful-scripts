# Redis Cluster Scripts

This directory contains simple Bash scripts to help you quickly start and stop a local Redis Cluster for development and testing purposes.

## Scripts

### `run_cluster.sh`
- **Purpose:** Launches a Redis Cluster with a configurable number of nodes and starting port.
- **Usage:**
  ```sh
  ./run_cluster.sh [number_of_nodes] [start_port]
  ```
  - `number_of_nodes` (optional): Number of Redis nodes to start (default: 6)
  - `start_port` (optional): Starting port number (default: 7000)
- **What it does:**
  - Creates directories and configuration files for each node.
  - Starts each Redis server instance in the background.
  - Initializes the cluster using `redis-cli --cluster create` with 1 replica per master.

### `stop_cluster.sh`
- **Purpose:** Stops all Redis nodes started by `run_cluster.sh` and cleans up their data/configuration directories.
- **Usage:**
  ```sh
  ./stop_cluster.sh [number_of_nodes] [start_port]
  ```
  - `number_of_nodes` (optional): Number of Redis nodes to stop (default: 6)
  - `start_port` (optional): Starting port number (default: 7000)
- **What it does:**
  - Shuts down each Redis server instance.
  - Removes data and configuration files for each node.

## Prerequisites
- [Redis](https://redis.io/) must be installed and available in your `PATH` (specifically `redis-server` and `redis-cli`).
- Scripts are designed for Unix-like systems (tested on macOS).

## Example
To start a 6-node cluster on ports 7000-7005:
```sh
./run_cluster.sh
```
To stop the cluster:
```sh
./stop_cluster.sh
```

## Notes
- These scripts are for local development/testing only. Do **not** use in production.
- All data will be deleted when stopping the cluster.
