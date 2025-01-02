#!/bin/bash
# docker compose down
sudo docker compose down

#clean containers
sudo docker conatiner rm -vf $(sudo docker ps -aq)

# clean images
sudo docker rmi -f $(sudo docker images -aq)

sudo docker system prune -f