# k8s

# Steps for installing Kubernetes on Debian

(Recommended to run each command one by one to catch any errors)

## Installation

```bash
# SSH into each node
gcloud compute ssh --zone "us-central1-c" "<node-one | node-two>" --project "<your project id>" 

# Install containerd
curl -LO https://github.com/containerd/containerd/releases/download/v2.1.4/containerd-2.1.4-linux-amd64.tar.gz

# Unpack and move to /usr/local
sudo tar Cxzvf /usr/local containerd-2.1.4-linux-amd64.tar.gz

# Make the systemd service directory and install the service file
sudo mkdir -p /usr/local/lib/systemd/system/
sudo curl -o /usr/local/lib/systemd/system/containerd.service https://raw.githubusercontent.com/containerd/containerd/main/containerd.service

# Reload systemd and start containerd
sudo systemctl daemon-reload
sudo systemctl enable --now containerd

# Install runc
curl -LO https://github.com/opencontainers/runc/releases/download/v1.3.0/runc.amd64

# Move it to /usr/local/sbin/runc
sudo install -m 755 runc.amd64 /usr/local/sbin/runc

# Make a new directory for CNI plugins and download them
sudo mkdir -p /opt/cni/bin
curl -LO https://github.com/containernetworking/plugins/releases/download/v1.7.1/cni-plugins-linux-amd64-v1.7.1.tgz
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.7.1.tgz

# Make the containerd config directory and generate the default config file
sudo mkdir -p /etc/containerd/
sudo sh -c 'containerd config default > /etc/containerd/config.toml'
```

Then use these commands to modify the config file for versions 2.x:
<https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd-systemd>

From here you can disable swap and install kubeadm, kubelet, and kubectl:

```bash
# Note: this command only temporarily disables swap. To make it persistent you will have to update config files like /etc/fstab
sudo swapoff -a

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# If it doesn't exist already
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add the kubernetes apt repository
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install kubeadm, kubectl, kubelet
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Enable the kubelet service before running kubeadm:
sudo systemctl enable --now kubelet

# Enable IP forwarding
sudo sysctl -w net.ipv4.ip_forward=1
```

The  kubelet is now restarting every few seconds, as it waits in a crashloop for kubeadm to tell it what to do.

## Creating a cluster with kubeadm

```bash
# Enable IP forwarding

# Initialize the cluster (take special note of the output join command)
sudo kubeadm init

# Enable the non-root user to access the cluster
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Now install the networking plugin (weave in this case)
kubectl apply -f https://reweave.azurewebsites.net/k8s/v1.33/net.yaml
```

## Join the cluster

On node-two (the worker node), run the command that was output by `kubeadm init` on node-one (the control plane node). It will look something like this:

```bash
kubeadm join <ip-addr>:6443 --token <token> \
        --discovery-token-ca-cert-hash <hash>
