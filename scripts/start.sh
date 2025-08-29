#!/bin/bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <NODE_IP>"
  exit 1
fi

NODE_IP="$1"
NODE_NAME="node-one"
POD_CIDR="10.244.0.0/16"

echo "Initializing Kubernetes control plane on node IP: $NODE_IP"

# 1. Initialize kubeadm
sudo kubeadm init \
  --apiserver-advertise-address="$NODE_IP" \
  --pod-network-cidr="$POD_CIDR" \
  --node-name="$NODE_NAME"

echo "Sleeping for 30 seconds to allow control plane components to start..."
sleep 30

# 2. Configure kubelet with explicit node IP
sudo sed -i "s#KUBELET_KUBEADM_ARGS=\"#KUBELET_KUBEADM_ARGS=\"--node-ip=$NODE_IP #" /var/lib/kubelet/kubeadm-flags.env
sudo systemctl daemon-reexec
sudo systemctl restart kubelet

# 3. Setup kubeconfig for current user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 4. Install Flannel CNI
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# 5. Restart kube-proxy pods to pick up correct node IP
kubectl -n kube-system delete pod -l k8s-app=kube-proxy

# 6. Verify
kubectl get nodes -o wide
kubectl get pods -n kube-system

echo "Kubernetes control plane setup complete."
