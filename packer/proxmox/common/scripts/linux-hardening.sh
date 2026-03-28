#!/usr/bin/env bash
# ================================================================
# File: packer/proxmox/common/scripts/linux-hardening.sh
# Purpose:
#   Apply the pragmatic hardening baseline agreed for Linux templates.
# ================================================================
set -euo pipefail

sudo mkdir -p /etc/ssh/sshd_config.d
sudo tee /etc/ssh/sshd_config.d/90-homelab-template.conf >/dev/null <<'EOF'
PasswordAuthentication yes
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding no
PermitRootLogin no
ClientAliveInterval 300
ClientAliveCountMax 2
EOF

sudo systemctl restart ssh || sudo systemctl restart sshd || true

if command -v dpkg-reconfigure >/dev/null 2>&1; then
  sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure tzdata >/dev/null 2>&1 || true
fi
