# Redis Compare Scripts

This directory contains Python scripts to compare keys and their contents between two Redis instances. These tools are useful for debugging, migration validation, or ensuring data consistency across Redis environments.

## Scripts

### `compare.py`
- **Purpose:**
  - Compares all keys (and their values) between two Redis instances.
  - Supports stripping hashtags or custom tags from keys for flexible comparison.
- **Usage:**
  ```sh
  python compare.py
  ```
  By default, it compares `redis://localhost:9000` and `redis://localhost:6379` with tags `[':{arenaPartition}', '_key']`.

  To customize, edit the `compare_redis_keys` call at the bottom of the script.
- **Features:**
  - Reports keys missing in either instance.
  - Compares values for all key types: string, hash, list, set, zset.
  - Reports type or content mismatches.

## Prerequisites
- Python 3.7+
- Install dependencies:
  ```sh
  pip install -r requirements.txt
  ```
- Both Redis instances must be accessible from your machine.

## Example
To compare two local Redis instances:
```sh
python compare.py
```

## Notes
- The script is intended for development and debugging, not for production use.
- You can adjust the Redis URLs and tags in the script as needed.
- For large datasets, the script may take time to scan all keys.
