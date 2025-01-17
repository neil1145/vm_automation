#!/bin/bash
set -e
IFNAME=$1
ADDRESS="$(ip -4 addr show $IFNAME | grep "inet" | head -1 | awk '{print $2}' | cut -d/ -f1)"

# Update the /etc/hosts file for the current host
sudo sed -e "s/^.*${HOSTNAME}.*/${ADDRESS} ${HOSTNAME} ${HOSTNAME}.local/" -i /etc/hosts

# Remove ubuntu-bionic entry
sudo sed -e '/^.*ubuntu-bionic.*/d' -i /etc/hosts

# Update /etc/hosts about other hosts
sudo bash -c "cat >> /etc/hosts <<EOF
192.168.56.19 kube-test-vm
192.168.56.17 test-node-2
EOF"