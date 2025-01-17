export DEBIAN_FRONTEND=noninteractive

echo "[TASK 1] Show whoami and change sudoers file"
whoami
echo "vagrant ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee -a /etc/ers


echo "[TASK 2] Stop and Disable firewall"
 systemctl disable --now ufw >/dev/null 2>&1

echo "[TASK 3] Letting iptables see bridged traffic"
 modprobe br_netfilter

echo "[TASK 4] Enable and Load Kernel modules"
echo "br_netfilter" | sudo tee /etc/modules-load.d/k8s.conf > /dev/null

echo "[TASK 5] Add Kernel settings"
echo -e "net.bridge.bridge-nf-call-ip6tables = 1\nnet.bridge.bridge-nf-call-iptables = 1" |  sudo tee /etc/sysctl.d/k8s.conf > /dev/null

# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

sudo sysctl --system

echo "[TASK 6] Install Docker"
sudo apt-get update -y
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
 curl -fsSL https://download.docker.com/linux/ubuntu/gpg |  sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
 echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

echo "[TASK 7] Configure Docker daemon"
sudo mkdir -p /etc/docker
echo '{
    "exec-opts": ["native.cgroupdriver=systemd"],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m"
    },
    "storage-driver": "overlay2"
}' | sudo tee /etc/docker/daemon.json > /dev/null

sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl status docker.service

echo "[TASK 8] Add Kubernetes apt repository"
# Ensure the keyrings directory exists
sudo mkdir -p /etc/apt/keyrings
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

sudo echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo "[TASK 9] Verify installation"
 docker --version
kubelet --version
kubeadm version
kubectl version --client
