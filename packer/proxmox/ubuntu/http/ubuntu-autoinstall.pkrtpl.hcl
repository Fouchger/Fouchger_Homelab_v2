#cloud-config
# ================================================================
# File: packer/proxmox/ubuntu/http/ubuntu-autoinstall.pkrtpl.hcl
# Purpose:
#   Render the Ubuntu autoinstall user-data consumed by the Packer HTTP
#   server during unattended template builds.
# ================================================================
autoinstall:
  version: 1
  locale: ${locale}
  keyboard:
    layout: ${keyboard_layout}
  timezone: ${timezone}
  identity:
    hostname: ${hostname}
    username: ${admin_username}
    password: ${admin_password_hash}
  ssh:
    install-server: true
    allow-pw: true
    authorized-keys:
      - ${ssh_public_key}
  packages:
    - qemu-guest-agent
    - cloud-init
    - curl
    - wget
    - sudo
    - ca-certificates
    - bash-completion
    - nano
  package_update: true
  package_upgrade: true
  storage:
    layout:
      name: direct
  late-commands:
    - curtin in-target --target=/target -- systemctl enable qemu-guest-agent
    - curtin in-target --target=/target -- systemctl enable ssh
