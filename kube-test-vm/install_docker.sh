#!/bin/bash

list=("docker.io" "docker-doc" "docker-compose" \
        "docker-compose-v2" "podman-docker" "containerd" "runc")

#for pkg in ; do sudo apt-get remove $pkg; done

echo -e "---- x Removing old packages x ----"

for pkg in ${list[@]}; do
    echo -e "\n removing $pkg"
    sudo apt-get remove $pkg
done

echo  -e "\n adding docker apt repository"

# Add Docker's official GPG key:
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y 

# installing docker

echo -e "\n -----+ Installing docker pkgs +------"
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 

echo -e "\n cereate new docker group if not present and add user to group"
sudo groupadd docker
sudo usermod -aG docker $USER

newgrp docker 

# Checking if installed 

echo -e "\n -----+ checking if installed +------"
sudo docker run hello-world

x=$(sudo docker run hello-world | grep -Eo "Hello from Docker!")
if [ "$x" == "Hello from Docker!" ]; then 
    echo "present" 
else 
    echo "not present" 
fi 