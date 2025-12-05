```

# Get into 
docker exec -it $(docker ps -a|grep <dockername> | awk ' { print $1 }') bash

# Get logpath
docker inspect $(docker ps -a|grep <dockername> | awk ' { print $1 }') | grep LogPath


```
