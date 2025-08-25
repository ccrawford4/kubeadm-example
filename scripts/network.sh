#!/bin/bash
set -euo pipefail

# Installation commands for containerd
commands=(
  "sudo apt-get update && sudo apt-get install -y kmod"            # Install kmod if not already installed
  "sudo modprobe br_netfilter"                                     # Load the kernel module
  "echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-iptables" # Enable bridge network filtering
  "echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward"                # Enable ip forwarding (important for pod networking)
)

# Run all commands
for command in "${commands[@]}"; do
  echo ">>> Running: $command"
  eval "$command"
done
