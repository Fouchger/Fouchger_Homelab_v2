# ================================================================
# File: packer/proxmox/variables.pkr.hcl
# Purpose:
#   Declare the shared inputs used by the curated Proxmox template
#   build catalogue.
#
# Notes:
#   - Local operator values are rendered into local.auto.pkrvars.hcl.
#   - Sensitive values must never be committed.
# ================================================================

variable "proxmox_url" {
  type        = string
  description = "Full Proxmox API URL including /api2/json."

  validation {
    condition     = can(regex("^https://.+/api2/json$", var.proxmox_url))
    error_message = "The proxmox_url value must be a full HTTPS Proxmox API URL ending in /api2/json."
  }
}

variable "proxmox_node" {
  type        = string
  description = "Proxmox node used for the build."
}

variable "proxmox_api_token_name" {
  type        = string
  description = "Proxmox API token name in the form user@realm!tokenid."
  sensitive   = true
}

variable "proxmox_api_token_value" {
  type        = string
  description = "Proxmox API token secret value."
  sensitive   = true
}

variable "insecure_skip_tls_verify" {
  type        = bool
  description = "Whether to skip Proxmox TLS verification."
  default     = true
}

variable "proxmox_iso_storage" {
  type        = string
  description = "Proxmox storage used for ISO images."
  default     = "local"
}

variable "proxmox_vm_storage" {
  type        = string
  description = "Proxmox storage used for VM disks."
  default     = "local-lvm"
}

variable "proxmox_cloud_init_storage" {
  type        = string
  description = "Proxmox storage used for cloud-init media."
  default     = "local"
}

variable "proxmox_bridge" {
  type        = string
  description = "Proxmox bridge used during template builds."
  default     = "vmbr0"
}

variable "admin_username" {
  type        = string
  description = "Default admin username baked into Linux templates."
  default     = "fouchger"
}

variable "admin_password" {
  type        = string
  description = "Default admin password used for the initial Packer connection and retained in the template."
  sensitive   = true
}

variable "admin_password_hash" {
  type        = string
  description = "SHA-512 password hash for the default admin user."
  sensitive   = true
}

variable "ssh_public_key" {
  type        = string
  description = "Public SSH key injected into Linux templates."
}

variable "timezone" {
  type        = string
  description = "Template timezone."
  default     = "Pacific/Auckland"
}

variable "locale" {
  type        = string
  description = "Template locale."
  default     = "en_NZ.UTF-8"
}

variable "keyboard_layout" {
  type        = string
  description = "Template keyboard layout."
  default     = "us"
}

variable "template_name_prefix" {
  type        = string
  description = "Prefix applied to generated template names."
  default     = "tpl"
}

variable "cpu_type" {
  type        = string
  description = "Virtual CPU model."
  default     = "host"
}

variable "machine_type" {
  type        = string
  description = "Proxmox machine type."
  default     = "q35"
}

variable "bios_type" {
  type        = string
  description = "Proxmox BIOS type."
  default     = "ovmf"

  validation {
    condition     = contains(["ovmf", "seabios"], var.bios_type)
    error_message = "The bios_type value must be either ovmf or seabios."
  }
}

variable "scsi_controller" {
  type        = string
  description = "Proxmox SCSI controller model."
  default     = "virtio-scsi-single"
}

variable "http_port_min" {
  type        = number
  description = "Minimum local HTTP port for Packer HTTP assets."
  default     = 8800
}

variable "http_port_max" {
  type        = number
  description = "Maximum local HTTP port for Packer HTTP assets."
  default     = 8899
}

variable "task_timeout" {
  type        = string
  description = "Timeout for Proxmox API tasks."
  default     = "30m"
}

variable "common_tags" {
  type        = list(string)
  description = "Common Proxmox tags applied to templates."
  default     = ["packer", "template", "homelab"]
}

variable "ubuntu_22_vmid" {
  type        = number
  description = "VMID for the Ubuntu 22 template."
  default     = 24001
}

variable "ubuntu_24_vmid" {
  type        = number
  description = "VMID for the Ubuntu 24 template."
  default     = 24002
}

variable "debian_12_vmid" {
  type        = number
  description = "VMID for the Debian 12 template."
  default     = 24021
}

variable "debian_13_vmid" {
  type        = number
  description = "VMID for the Debian 13 template."
  default     = 24022
}

variable "talos_1_12_4_vmid" {
  type        = number
  description = "VMID for the Talos 1.12.4 template."
  default     = 24041
}

variable "talos_1_12_5_vmid" {
  type        = number
  description = "VMID for the Talos 1.12.5 template."
  default     = 24042
}

variable "ubuntu_22_iso_filename" {
  type        = string
  description = "Ubuntu 22 ISO filename stored on Proxmox."
  default     = "ubuntu-22.04.5-live-server-amd64.iso"
}

variable "ubuntu_22_iso_url" {
  type        = string
  description = "Ubuntu 22 ISO source URL used by download tasks."
  default     = "https://releases.ubuntu.com/releases/22.04/ubuntu-22.04.5-live-server-amd64.iso"
}

variable "ubuntu_22_iso_checksum" {
  type        = string
  description = "Ubuntu 22 ISO checksum in Packer format."
  default     = "sha256:9bc6028870aef3f74f4e2dd6d3c0b0b3dde3532e78be57f16ff7ee69ae690835"
}

variable "ubuntu_24_iso_filename" {
  type        = string
  description = "Ubuntu 24 ISO filename stored on Proxmox."
  default     = "ubuntu-24.04.4-live-server-amd64.iso"
}

variable "ubuntu_24_iso_url" {
  type        = string
  description = "Ubuntu 24 ISO source URL used by download tasks."
  default     = "https://releases.ubuntu.com/24.04/ubuntu-24.04.4-live-server-amd64.iso"
}

variable "ubuntu_24_iso_checksum" {
  type        = string
  description = "Ubuntu 24 ISO checksum in Packer format."
  default     = "sha256:e907d92eeec9df64163a7e454cbc8d7755e8ddc7ed42f99dbc80c40f1a138433"
}

variable "debian_12_iso_filename" {
  type        = string
  description = "Debian 12 netinst ISO filename stored on Proxmox."
  default     = "debian-12.13.0-amd64-netinst.iso"
}

variable "debian_12_iso_url" {
  type        = string
  description = "Debian 12 ISO source URL used by download tasks."
  default     = "https://cdimage.debian.org/mirror/cdimage/archive/12.13.0/amd64/iso-cd/debian-12.13.0-amd64-netinst.iso"
}

variable "debian_12_iso_checksum" {
  type        = string
  description = "Debian 12 ISO checksum in Packer format."
  default     = "sha512:REPLACE_ME_DEBIAN_12_SHA512"
}

variable "debian_13_iso_filename" {
  type        = string
  description = "Debian 13 netinst ISO filename stored on Proxmox."
  default     = "debian-13.4.0-amd64-netinst.iso"
}

variable "debian_13_iso_url" {
  type        = string
  description = "Debian 13 ISO source URL used by download tasks."
  default     = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-13.4.0-amd64-netinst.iso"
}

variable "debian_13_iso_checksum" {
  type        = string
  description = "Debian 13 ISO checksum in Packer format."
  default     = "sha512:REPLACE_ME_DEBIAN_13_SHA512"
}

variable "talos_1_12_4_iso_filename" {
  type        = string
  description = "Talos 1.12.4 ISO filename stored on Proxmox."
  default     = "talos-metal-amd64-v1.12.4.iso"
}

variable "talos_1_12_4_iso_url" {
  type        = string
  description = "Talos 1.12.4 ISO source URL used by download tasks."
  default     = "https://factory.talos.dev/image/metal/amd64/1.12.4/metal-amd64.iso"
}

variable "talos_1_12_4_iso_checksum" {
  type        = string
  description = "Talos 1.12.4 ISO checksum in Packer format."
  default     = "sha256:REPLACE_ME_TALOS_1_12_4_SHA256"
}

variable "talos_1_12_5_iso_filename" {
  type        = string
  description = "Talos 1.12.5 ISO filename stored on Proxmox."
  default     = "talos-metal-amd64-v1.12.5.iso"
}

variable "talos_1_12_5_iso_url" {
  type        = string
  description = "Talos 1.12.5 ISO source URL used by download tasks."
  default     = "https://factory.talos.dev/image/metal/amd64/1.12.5/metal-amd64.iso"
}

variable "talos_1_12_5_iso_checksum" {
  type        = string
  description = "Talos 1.12.5 ISO checksum in Packer format."
  default     = "sha256:658b5579958273c135a11eb89528a7d917c86b7d7d39e59510dcb245d825fde2"
}
