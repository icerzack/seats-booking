#!/bin/bash
# Логирование для отладки
exec > >(tee -a /var/log/install-k8s.log) 2>&1

echo "[$(date)] Starting Kubernetes installation"

# Отключаем swap
echo "[$(date)] Disabling swap"
swapoff -a
sed -i '/swap/d' /etc/fstab

# Установка iptables и настройка модулей ядра
echo "[$(date)] Setting up kernel modules"
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

echo "[$(date)] Loading kernel modules"
sudo modprobe overlay
sudo modprobe br_netfilter

echo "[$(date)] Configuring sysctl parameters"
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

# Установка kubeadm, kubelet и kubectl
echo "[$(date)] Adding Kubernetes repository key"
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
if [ $? -ne 0 ]; then
  echo "[$(date)] ERROR: Failed to add Kubernetes GPG key"
  exit 1
fi

echo "[$(date)] Adding Kubernetes repository"
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
if [ $? -ne 0 ]; then
  echo "[$(date)] ERROR: Failed to add Kubernetes repository"
  exit 1
fi

echo "[$(date)] Updating apt repositories"
sudo apt-get update
if [ $? -ne 0 ]; then
  echo "[$(date)] ERROR: Failed to update apt repositories"
  exit 1
fi

echo "[$(date)] Installing Kubernetes components"
sudo apt-get install -y kubelet kubeadm kubectl
if [ $? -ne 0 ]; then
  echo "[$(date)] ERROR: Failed to install Kubernetes components"
  exit 1
fi

echo "[$(date)] Holding Kubernetes packages at current version"
sudo apt-mark hold kubelet kubeadm kubectl

# Инициализация кластера
echo "[$(date)] Initializing Kubernetes cluster"
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
if [ $? -ne 0 ]; then
  echo "[$(date)] ERROR: Failed to initialize Kubernetes cluster"
  exit 1
fi

# Настройка kubectl для пользователя root
echo "[$(date)] Configuring kubectl for root user"
mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config
chown $(id -u):$(id -g) /root/.kube/config

# Установка сети Flannel
echo "[$(date)] Installing Flannel CNI"
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
if [ $? -ne 0 ]; then
  echo "[$(date)] ERROR: Failed to install Flannel network"
  exit 1
fi

# Разрешаем запуск подов на master-ноде
echo "[$(date)] Allowing pods on control-plane node"
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
if [ $? -ne 0 ]; then
  echo "[$(date)] WARNING: Failed to remove control-plane taint"
  # This is not critical, so we continue
fi

echo "[$(date)] Verifying cluster status"
kubectl get nodes
kubectl cluster-info

echo "[$(date)] Kubernetes installation completed successfully" 