#!/bin/bash
set -euo pipefail

# Installation commands for containerd
commands=(
  "curl -LO https://github.com/containerd/containerd/releases/download/v2.1.4/containerd-2.1.4-linux-amd64.tar.gz"
  "sudo tar Cxzvf /usr/local containerd-2.1.4-linux-amd64.tar.gz"
  "sudo mkdir -p /usr/local/lib/systemd/system/"
  "sudo curl -o /usr/local/lib/systemd/system/containerd.service https://raw.githubusercontent.com/containerd/containerd/main/containerd.service"
  "sudo systemctl daemon-reload"
  "sudo systemctl enable --now containerd"
  "curl -LO https://github.com/opencontainers/runc/releases/download/v1.3.0/runc.amd64"
  "sudo install -m 755 runc.amd64 /usr/local/sbin/runc"
  "sudo mkdir -p /opt/cni/bin"
  "curl -LO https://github.com/containernetworking/plugins/releases/download/v1.7.1/cni-plugins-linux-amd64-v1.7.1.tgz"
  "sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.7.1.tgz"
  "sudo mkdir -p /etc/containerd/"
  "sudo sh -c 'containerd config default > /etc/containerd/config.toml'"
)

# Run all commands
for command in "${commands[@]}"; do
  echo ">>> Running: $command"
  eval "$command"
done
