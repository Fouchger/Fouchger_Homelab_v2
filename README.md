# Fouchger Homelab_v2

Homelab automation, implementation planning, and architecture baseline for the Fouchger environment.

## Purpose

This repository is the source-controlled starting point for building and operating the homelab using a coordinated toolchain built around Proxmox, Packer, Terraform, Ansible, Taskfiles, and Proxmox Helper Scripts.

It contains:

- bootstrap and operator entrypoint scripts
- task definitions for common workflows
- environment examples and local state scaffolding
- architecture, build, and implementation documentation under `docs/architecture/`

## Current Scope

The repository currently focuses on:

- production-oriented architecture and migration planning
- phase-one build documentation for the current hardware reality
- bootstrap tooling and workflow structure
- early automation standards for the repo-driven build path

## Quick Start

### Option 1: Bootstrap directly from GitHub

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Fouchger/Fouchger_Homelab_v2/refs/heads/main1/install.sh)"
```

### Option 2: Run locally from an existing clone

```bash
./install.sh
```
