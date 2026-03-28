# ================================================================
# File: packer/proxmox/plugins.pkr.hcl
# Purpose:
#   Pin the Packer plugins required by the curated Proxmox template
#   build workflow.
#
# Notes:
#   - Plugin versions are pinned explicitly for reproducibility.
#   - Upgrade intentionally via `packer init --upgrade .` after review.
# ================================================================

packer {
  required_plugins {
    proxmox = {
      source  = "github.com/hashicorp/proxmox"
      version = "= 1.2.3"
    }
  }
}
