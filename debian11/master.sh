#!/bin/bash

IP=$(hostname -I | awk '{ print $1 }')

#Pull required containers"
kubeadm config images pull >/dev/null 2>&1

#Initialize Kubernetes Cluster"
kubeadm init --apiserver-advertise-address=$IP --pod-network-cidr=10.245.0.0/16 >> /root/kubeinit.log 2>/dev/null

#Initialize kubeconfig
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=/etc/kubernetes/admin.conf

# Deploy Calico network"
kubectl create -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml
kubectl apply -f ./calico.yaml

#Generate and save cluster join command to joincluster.txt"
kubeadm token create --print-join-command > joincluster.txt 2>/dev/null
