#!/usr/bin/env python
import json
import re
import redis
from typing import Set

def get_keys(redis: redis.Redis, pattern: str) -> Set[str]:
    """Fetch and return keys from Redis that match a given pattern."""
    cursor = b'0'
    keys = set()
    while cursor:
        cursor, data = redis.scan(match=pattern, cursor=cursor)
        keys.update(data)
    return keys

def strip_hashtag(key: str, tags: list) -> str:
    """Strip the hashtag (':{arenaPartition}') from a key."""
    for tag in tags:
        hashtag_index = key.find(tag)
        if hashtag_index != -1:
            return key[:hashtag_index]
    return key

def compare_redis_keys(
    redis1_url: str, redis2_url: str,
    tags: list
) -> None:
    """Compare keys and their contents from two Redis instances."""
    redis1 = redis.from_url(redis1_url)
    redis2 = redis.from_url(redis2_url)

    try:
        keys_1 = get_keys(redis1, '*')
        keys_2 = get_keys(redis2, '*')

        keys_1_dic = {strip_hashtag(key.decode('utf-8'), tags=tags): key.decode('utf-8') for key in keys_1}
        keys_2_dic = {strip_hashtag(key.decode('utf-8'), tags=tags): key.decode('utf-8') for key in keys_2}

        missing_in_redis2 = keys_1_dic.keys() - keys_2_dic.keys()
        missing_in_redis1 = keys_2_dic.keys() - keys_1_dic.keys()

        if missing_in_redis2 or missing_in_redis1:
            print(f"Keys missing in Redis 2: {json.dumps(list(missing_in_redis2), indent=2)}")
            print(f"Keys missing in Redis 1: {json.dumps(list(missing_in_redis1), indent=2)}")
        else:
            print("All keys match between Redis instances.")

        common_keys_with_arena = {key: [keys_1_dic[key], keys_2_dic[key]]
                                  for key in keys_1_dic.keys() & keys_2_dic.keys()}

        [compare_key_content(redis1, redis2, key_with_arena[0], key_with_arena[1])
                               for key, key_with_arena in common_keys_with_arena.items()]

    except Exception as e:
        print(f"Error: {e}")
    finally:
        redis1.close()
        redis2.close()

def string_to_float_if_possible(s):
    """
    Converts a string to a float if possible.
    Returns the float value if the conversion is successful,
    otherwise returns the original string.
    """
    try:
        return float(s)
    except ValueError:
        return s

def clean_and_sort_dict(d: dict) -> dict:
    """Convert keys to str and sort a dictionary."""
    return {k.decode('utf-8'): string_to_float_if_possible(v.decode('utf-8')) for k, v in d.items()}

def compare_key_content(redis1: redis.Redis, redis2: redis.Redis, key1: str, key2: str) -> None:
    """Compare contents of a key between two Redis instances."""
    try:
        type1 = redis1.type(key1)
        type2 = redis2.type(key2)

        if type1 != type2:
            print(f"Type mismatch for {key1} : {type1} and {key2} : {type2}")
            return

        match type1:
            case b'string':
                value1 = redis1.get(key1)
                value2 = redis2.get(key2)
            case b'hash':
                value1 = clean_and_sort_dict(redis1.hgetall(key1))
                value2 = clean_and_sort_dict(redis2.hgetall(key2))
            case b'list':
                value1 = redis1.lrange(key1, 0, -1)
                value2 = redis2.lrange(key2, 0, -1)
            case b'set':
                value1 = redis1.smembers(key1)
                value2 = redis2.smembers(key2)
            case b'zset':
                value1 = redis1.zrange(key1, 0, -1)
                value2 = redis2.zrange(key2, 0, -1)
            case _:
                print(f"Unsupported type for key: {key1}")
                return

        if value1 != value2:
            print(f"Content mismatch for keys {key1} and {key2} type: {type1.decode('utf-8')}")

    except Exception as e:
        print(f"Error comparing contents for keys {key1} and {key2}: {e}")

if __name__ == "__main__":
    compare_redis_keys("redis://localhost:9000", "redis://localhost:6379", tags=[r':{arenaPartition}', r'_key'])

