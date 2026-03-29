# ================================================================
# File: packer/proxmox/local.auto.pkrvars.example.hcl
# Purpose:
#   Example local-only values for Packer Proxmox template builds.
#
# Notes:
#   - Copy to local.auto.pkrvars.hcl only on the operator workstation.
#   - Real secrets should be rendered via task packer:vars:render.
# ================================================================
proxmox_url              = "https://192.168.88.250:8006/api2/json"
proxmox_node             = "pve01"
proxmox_api_token_name   = "automation@pve!automation-token"
proxmox_api_token_value  = "REPLACE_ME"
insecure_skip_tls_verify = true
proxmox_iso_storage      = "local"
proxmox_vm_storage       = "local-lvm"
proxmox_cloud_init_storage = "local"
proxmox_bridge           = "vmbr0"
admin_username           = "fouchger"
admin_password           = "REPLACE_ME"
admin_password_hash      = "REPLACE_ME"
ssh_public_key           = "ssh-ed25519 REPLACE_ME"
timezone                 = "Pacific/Auckland"
locale                   = "en_NZ.UTF-8"
keyboard_layout          = "us"
