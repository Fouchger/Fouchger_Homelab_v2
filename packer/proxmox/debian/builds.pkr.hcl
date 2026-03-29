# ================================================================
# File: packer/proxmox/debian/builds.pkr.hcl
# Purpose:
#   Define the curated Debian build blocks and shared Linux provisioners.
#
# Notes:
#   - Provisioner order matters in Packer HCL, so baseline, hardening,
#     and cleanup are kept in an explicit sequence.
#   - Shared guest scripts are kept under common/scripts to avoid duplication
#     across OS-specific build folders.
# ================================================================

build {
  name    = "debian-12"
  sources = ["source.proxmox-iso.debian-12"]

  provisioner "shell" {
    environment_vars = local.linux_shell_environment
    execute_command  = "echo '${var.admin_password}' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    scripts = [
      "${path.root}/common/scripts/linux-baseline.sh",
      "${path.root}/common/scripts/linux-hardening.sh",
      "${path.root}/common/scripts/linux-cleanup.sh",
    ]
  }
}

build {
  name    = "debian-13"
  sources = ["source.proxmox-iso.debian-13"]

  provisioner "shell" {
    environment_vars = local.linux_shell_environment
    execute_command  = "echo '${var.admin_password}' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    scripts = [
      "${path.root}/common/scripts/linux-baseline.sh",
      "${path.root}/common/scripts/linux-hardening.sh",
      "${path.root}/common/scripts/linux-cleanup.sh",
    ]
  }
}
