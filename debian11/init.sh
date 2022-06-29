#!/bin/bash

#Tested only Debian 11 and Kubernetes ver 1.24

#Disable and turn off SWAP"
sed -i '/swap/d' /etc/fstab
swapoff -a

#Enable and Load Kernel modules"
cat >>/etc/modules-load.d/containerd.conf<<EOF
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

#Add Kernel settings"
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system >/dev/null 2>&1

#Install containerd runtime"
apt update >/dev/null 2>&1
apt install -y containerd apt-transport-https ca-certificates curl >/dev/null 2>&1
mkdir /etc/containerd
containerd config default > /etc/containerd/config.toml
sed -i '/plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options/a \            SystemdCgroup = true' /etc/containerd/config.toml 
systemctl restart containerd
systemctl enable containerd >/dev/null 2>&1

#Add apt repo for kubernetes"
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

#Install Kubernetes components (kubeadm, kubelet and kubectl)"
apt update >/dev/null 2>&1
apt install -y kubeadm kubelet kubectl >/dev/null 2>&1
apt-mark hold kubelet kubeadm kubectl >/dev/null 2>&1

