# ================================================================
# File: packer/proxmox/ubuntu/ubuntu-24.pkr.hcl
# Purpose:
#   Build the Ubuntu 24.04 Proxmox template using the curated ISO-driven
#   autoinstall path.
#
# Notes:
#   - The ISO must be present on Proxmox local ISO storage before build.
#   - Cloud-init is enabled on the final template for Terraform cloning.
# ================================================================

source "proxmox-iso" "ubuntu-24" {
  proxmox_url              = var.proxmox_url
  insecure_skip_tls_verify = var.insecure_skip_tls_verify
  username                 = var.proxmox_api_token_name
  token                    = var.proxmox_api_token_value
  node                     = var.proxmox_node
  vm_id                    = var.ubuntu_24_vmid
  vm_name                  = local.template_names.ubuntu_24
  template_name            = local.template_names.ubuntu_24
  template_description     = local.template_descriptions.ubuntu_24
  task_timeout             = var.task_timeout
  tags                     = join(";", concat(var.common_tags, ["ubuntu", "ubuntu-24", "linux"]))

  machine         = var.machine_type
  bios            = var.bios_type
  scsi_controller = var.scsi_controller
  qemu_agent      = true
  onboot          = false
  cloud_init      = true
  cloud_init_storage_pool = var.proxmox_cloud_init_storage
  cloud_init_disk_type    = "ide"

  os       = "l26"
  cpu_type = var.cpu_type
  sockets  = 1
  cores    = 2
  memory   = 2048

  network_adapters {
    model  = "virtio"
    bridge = var.proxmox_bridge
  }

  disks {
    type         = "scsi"
    storage_pool = var.proxmox_vm_storage
    disk_size    = "16G"
    cache_mode   = "none"
  }

  efi_config {
    efi_storage_pool  = var.proxmox_vm_storage
    efi_type          = "4m"
    pre_enrolled_keys = true
  }

  boot_iso {
    type         = "scsi"
    iso_file     = "${var.proxmox_iso_storage}:iso/${var.ubuntu_24_iso_filename}"
    iso_checksum = var.ubuntu_24_iso_checksum
    unmount      = true
  }

  http_content = {
    "/ubuntu-24/meta-data" = "instance-id: ubuntu-24\nlocal-hostname: ${local.template_names.ubuntu_24}\n"
    "/ubuntu-24/user-data" = templatefile("${path.root}/ubuntu/http/ubuntu-autoinstall.pkrtpl.hcl", {
      hostname            = local.template_names.ubuntu_24
      admin_username      = var.admin_username
      admin_password_hash = var.admin_password_hash
      ssh_public_key      = var.ssh_public_key
      timezone            = var.timezone
      locale              = var.locale
      keyboard_layout     = var.keyboard_layout
    })
  }

  http_port_min = var.http_port_min
  http_port_max = var.http_port_max

  boot_wait = "8s"
  boot_command = [
    "c<wait>",
    "linux /casper/vmlinuz --- autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ubuntu-24/ <enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "boot<enter>"
  ]

  ssh_username = var.admin_username
  ssh_password = var.admin_password
  ssh_timeout  = "45m"
}
