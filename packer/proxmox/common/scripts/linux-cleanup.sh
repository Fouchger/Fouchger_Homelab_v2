#!/usr/bin/env bash
# ================================================================
# File: packer/proxmox/common/scripts/linux-cleanup.sh
# Purpose:
#   Clean the guest so Terraform clones start from a neutral baseline.
# ================================================================
set -euo pipefail

sudo cloud-init clean --logs || true
sudo truncate -s 0 /etc/machine-id || true
sudo rm -f /var/lib/dbus/machine-id || true
sudo ln -sf /etc/machine-id /var/lib/dbus/machine-id || true
sudo apt-get autoremove -y
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*
sudo rm -rf /tmp/* /var/tmp/*
