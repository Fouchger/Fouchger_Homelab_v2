# ================================================================
# File: packer/proxmox/locals.pkr.hcl
# Purpose:
#   Centralise derived values used across the curated Proxmox template
#   catalogue.
#
# Notes:
#   - All template names are normalised for Terraform-safe consumption.
#   - Common template descriptions are generated consistently.
# ================================================================

locals {
  build_timestamp = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())

  common_tag_string = join(";", var.common_tags)

  template_names = {
    ubuntu_22   = "${var.template_name_prefix}-ubuntu-22"
    ubuntu_24   = "${var.template_name_prefix}-ubuntu-24"
    debian_12   = "${var.template_name_prefix}-debian-12"
    debian_13   = "${var.template_name_prefix}-debian-13"
    talos_1_12_4 = "${var.template_name_prefix}-talos-1-12-4"
    talos_1_12_5 = "${var.template_name_prefix}-talos-1-12-5"
  }

  template_descriptions = {
    ubuntu_22 = "Ubuntu 22.04 template built by Packer on ${local.build_timestamp}"
    ubuntu_24 = "Ubuntu 24.04 template built by Packer on ${local.build_timestamp}"
    debian_12 = "Debian 12 template built by Packer on ${local.build_timestamp}"
    debian_13 = "Debian 13 template built by Packer on ${local.build_timestamp}"
    talos_1_12_4 = "Talos 1.12.4 template scaffold built by Packer on ${local.build_timestamp}"
    talos_1_12_5 = "Talos 1.12.5 template scaffold built by Packer on ${local.build_timestamp}"
  }

  linux_shell_environment = [
    "DEBIAN_FRONTEND=noninteractive",
    "TZ=${var.timezone}",
    "LC_ALL=C.UTF-8",
  ]
}
