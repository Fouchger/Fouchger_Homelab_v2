# ================================================================
# File: packer/proxmox/ubuntu/builds.pkr.hcl
# Purpose:
#   Define the curated Ubuntu build blocks and shared Linux provisioners.
#
# Notes:
#   - Provisioner order matters in Packer HCL, so baseline, hardening,
#     and cleanup are kept in an explicit sequence.
#   - Shared guest scripts are kept under common/scripts to avoid duplication
#     across OS-specific build folders.
# ================================================================

build {
  name    = "ubuntu-22"
  sources = ["source.proxmox-iso.ubuntu-22"]

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
  name    = "ubuntu-24"
  sources = ["source.proxmox-iso.ubuntu-24"]

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


