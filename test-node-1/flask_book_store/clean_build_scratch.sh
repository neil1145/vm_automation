#!/bin/bash
# docker compose down
 docker compose down

#clean containers
 docker conatiner rm -fv $( docker ps -aq)

# clean images
 docker rmi -f $( docker images -aq)

 docker system prune 