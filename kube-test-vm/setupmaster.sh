#!/bin/bash

sudo mkdir -p /etc/containerd
#sudo containerd config default > /etc/containerd/config.toml

echo "[TASK 1] Pull required containers"
sudo kubeadm config images pull >/dev/null 2>&1

echo "[TASK 2] Initialize Kubernetes Cluster"
#kubeadm init --apiserver-advertise-address=172.16.16.100 --pod-network-cidr=192.168.0.0/16 >> /root/kubeinit.log 2>/dev/null
sudo kubeadm init --pod-network-cidr 192.168.0.0/16 --apiserver-advertise-address=192.168.56.19 2>> /vagrant/kubeinit.log

echo "[TASK 3] Deploy Calico network"
sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.29.1/manifests/calico.yaml >/dev/null 2>&1

# echo "[TASK 3] Deploy Weave network"
# kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

echo "[TASK 4] Generate and save cluster join command to /joincluster.sh"
sudo kubeadm token create --print-join-command > /vagrant/joincluster.sh 2>/dev/null

#echo "[TASK 5] Setup public key for workers to access master"
#echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDkQqtnAx7MYMLP+UcTdQCXBYtGXqY2PWI6uGtuiCEclIRNY5WDy1HvUGkotEb/Om7LCAvho7t6qHPgPNB2Vsm7Opx6pgmjLcQMr4apFIX6F1InSYONXzqPPCywO7tCmh5ss7zQCSlrwy+jtmE7xDAtgrJGFGdJTIq7V6aCSGbW5p4GV1469BkfVPDGwIypmYzhVQDMesJs5dASTGMYsDWLaxPbuIRGpYsgrc8v7xcrijW22c6U/8MNWEsC34OPKBUzBz042LnpBNCq/8wfd8oNNlWWyJhWDKXCYQa1TM7BkwJG94Me2ehLu2RzCHn7qFHaE/yXzSxHM6b+GzYuexWF vagrant@kube-test-vm" | sudo tee ~/.ssh/authorized_keys

echo "[TASK 6] Setup kubectl"
sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config