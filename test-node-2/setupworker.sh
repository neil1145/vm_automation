#!/bin/bash

echo "[TASK 1] Join node to Kubernetes Cluster private key"

echo "[TASK 2] Change private key permission"
chmod 400 /vagrant/vm-key

echo "[TASK 3] Pull cluster connection token"
sudo scp -i /vagrant/vm-key -o StrictHostKeyChecking=no vagrant@192.168.56.19:/vagrant/joincluster.sh /vagrant/joincluster.sh

echo "[Task 4] Join the cluster"
sudo bash -c /vagrant/joincluster.sh