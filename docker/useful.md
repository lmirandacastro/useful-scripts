```

# Get into redis
docker exec -it $(docker ps -a|grep redis | awk ' { print $1 }') bash

# Get into ratequeue
docker exec -it $(docker ps -a|grep redis | awk ' { print $1 }') bash

docker inspect $(docker ps -a|grep ratequeue | awk ' { print $1 }') | grep LogPath


```
