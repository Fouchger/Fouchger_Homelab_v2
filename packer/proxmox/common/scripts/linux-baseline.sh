#!/usr/bin/env bash
# ================================================================
# File: packer/proxmox/common/scripts/linux-baseline.sh
# Purpose:
#   Apply the baseline package and platform configuration expected for
#   cloned Linux templates in this homelab.
# ================================================================
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update -y
sudo apt-get install -y \
  qemu-guest-agent \
  cloud-init \
  curl \
  wget \
  sudo \
  ca-certificates \
  bash-completion \
  nano

sudo timedatectl set-timezone "${TZ:-Pacific/Auckland}" || true
sudo systemctl enable qemu-guest-agent
sudo systemctl enable ssh
