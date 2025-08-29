# k8s

# Create the VMs

```bash
# Assuming you have gcloud installed and configured
gcloud auth login

# Navigate to the terraform directory
cd terraform/stacks/vms

# Initialize, plan, and apply
terraform init
terraform plan -out plan.out
terraform apply plan.out
```

# SSH into VMS

```bash
# For node one
gcloud compute ssh --zone "us-central1-c" "node-one" --project <project-id>

# For node two
 gcloud compute ssh --zone "us-central1-c" "node-two" --project <project-id>
```

On each node install `git` and clone the repository:

```bash
sudo apt-get -y install git
git clone https://github.com/ccrawford4/k8s.git && cd k8s
```

# Steps for installing Kubernetes on Debian

## Container Runtime Installation

```bash
# in the root directory
./scripts/init.sh
```

Then use these commands to modify the config file for versions 2.x:
<https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd-systemd>

Then use this to setup bridge networking and IP forwarding (necessary for pod networking in kubernetes):

```bash
./scripts/network.sh
```

Then use the following script to disable swap and install kubeadm, kubectl, and kubelet:

```bash
./scripts/install.sh
```

The  kubelet is now restarting every few seconds, as it waits in a crashloop for kubeadm to tell it what to do.

## Creating a cluster with kubeadm

```bash
# Initialize the cluster (take special note of the output join command)
# Get your nodes IP address: ip route show (use the default addr)
./scripts/start.sh <node-ip-address>
```

## Join the cluster

On node-two (the worker node), run the command that was output by `kubeadm init` on node-one (the control plane node). It will look something like this:

```bash
kubeadm join <ip-addr>:6443 --token <token> \
        --discovery-token-ca-cert-hash <hash>
```

You should see a message like so:

```bash
This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.
```

If you navigate back to the master node ('node-one') and run:

```bash
kubectl get nodes
```

You should see both nodes listed as part of the cluster:

```bash
NAME       STATUS   ROLES           AGE     VERSION
node-one   Ready    control-plane   10m     v1.30.14
node-two   Ready    <none>          3m18s   v1.30.14
