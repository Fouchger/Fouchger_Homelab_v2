# ================================================================
# File: packer/proxmox/debian/debian-13.pkr.hcl
# Purpose:
#   Build the Debian 13 Proxmox template using the curated netinst ISO
#   and preseed-driven unattended install path.
#
# Notes:
#   - The ISO must be present on Proxmox local ISO storage before build.
#   - SeaBIOS is used here because Debian netinst unattended booting is
#     more deterministic through the BIOS installer path than the OVMF
#     menu-edit path.
#   - Cloud-init is enabled on the final template for Terraform cloning.
# ================================================================

source "proxmox-iso" "debian-13" {
  proxmox_url              = var.proxmox_url
  insecure_skip_tls_verify = var.insecure_skip_tls_verify
  username                 = var.proxmox_api_token_name
  token                    = var.proxmox_api_token_value
  node                     = var.proxmox_node
  vm_id                    = var.debian_13_vmid
  vm_name                  = local.template_names.debian_13
  template_name            = local.template_names.debian_13
  template_description     = local.template_descriptions.debian_13
  task_timeout             = var.task_timeout
  tags                     = join(";", concat(var.common_tags, ["debian", "debian-13", "linux"]))

  machine         = var.machine_type
  bios            = "seabios"
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

  boot_iso {
    type         = "scsi"
    iso_file     = "${var.proxmox_iso_storage}:iso/${var.debian_13_iso_filename}"
    iso_checksum = var.debian_13_iso_checksum
    unmount      = true
  }

  http_content = {
    "/debian-13/preseed.cfg" = templatefile("${path.root}/debian/http/debian-preseed.pkrtpl.hcl", {
      hostname            = local.template_names.debian_13
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

  boot_wait = "6s"
  boot_command = [
    "<esc><wait>",
    "auto ",
    "priority=critical ",
    "url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian-13/preseed.cfg ",
    "debian-installer/locale=${var.locale} ",
    "keyboard-configuration/xkb-keymap=${var.keyboard_layout} ",
    "hostname=${local.template_names.debian_13} ",
    "initrd=/install.amd/initrd.gz ",
    "--- <enter>"
  ]

  ssh_username = var.admin_username
  ssh_password = var.admin_password
  ssh_timeout  = "45m"
}
