#!/usr/bin/env python3
# ================================================================
# File: packer/scripts/build_talos_template.py
# Purpose:
#   Build a Talos Proxmox template by generating a custom Image Factory
#   schematic, downloading the NoCloud raw disk image on the Proxmox host,
#   and importing it as a reusable VM template.
#
# Notes:
#   - This path is intentionally separate from the ISO-driven Packer flow.
#   - Talos is delivered as an image, so the Proxmox host imports a raw disk
#     and converts it to a template.
#   - SSH is used to execute qm commands directly on the target Proxmox node.
# ================================================================
from __future__ import annotations

import argparse
import json
import os
import shlex
import subprocess
import sys
import urllib.request
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parents[2]
STATE_DIR = ROOT_DIR / "state"
CONFIG_ENV = STATE_DIR / "configs" / ".env"
SCHEMATIC_FILE = ROOT_DIR / "packer" / "proxmox" / "talos" / "files" / "schematic.yaml"
IMAGE_FACTORY_BASE = "https://factory.talos.dev"


def read_env_file(path: Path) -> dict[str, str]:
    data: dict[str, str] = {}
    if not path.exists():
        raise FileNotFoundError(f"Required env file not found: {path}")
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        data[key.strip()] = value.strip()
    return data


def post_schematic(schematic_yaml: str) -> str:
    request = urllib.request.Request(
        f"{IMAGE_FACTORY_BASE}/schematics",
        data=schematic_yaml.encode("utf-8"),
        headers={"Content-Type": "application/yaml"},
        method="POST",
    )
    with urllib.request.urlopen(request, timeout=60) as response:
        payload = json.loads(response.read().decode("utf-8"))
    schematic_id = payload.get("id", "").strip()
    if not schematic_id:
        raise RuntimeError("Image Factory did not return a schematic ID.")
    return schematic_id


def run_ssh(host: str, user: str, ssh_key: Path, known_hosts: Path, remote_script: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [
            "ssh",
            "-i",
            str(ssh_key),
            "-o",
            "BatchMode=yes",
            "-o",
            "StrictHostKeyChecking=accept-new",
            "-o",
            f"UserKnownHostsFile={known_hosts}",
            f"{user}@{host}",
            "bash",
            "-s",
        ],
        input=remote_script,
        text=True,
        capture_output=True,
        check=False,
    )


def build_remote_script(
    *,
    vmid: int,
    template_name: str,
    talos_version: str,
    schematic_id: str,
    vm_storage: str,
    bridge: str,
    machine_type: str,
    bios_type: str,
    scsi_controller: str,
    cpu_type: str,
    memory_mb: int,
    cores: int,
    sockets: int,
) -> str:
    image_url = f"{IMAGE_FACTORY_BASE}/image/{schematic_id}/{talos_version}/nocloud-amd64.raw.xz"
    remote_raw_xz = f"/var/tmp/{template_name}.raw.xz"
    remote_raw = f"/var/tmp/{template_name}.raw"
    efi_disk = f"{vm_storage}:0,efitype=4m,pre-enrolled-keys=1"

    # Proxmox CLI expects virtio-scsi-pci, while Talos docs/UI wording commonly says VirtIO SCSI.
    qm_scsi = "virtio-scsi-pci" if scsi_controller in {"virtio-scsi", "virtio-scsi-pci", "virtio-scsi-single"} else scsi_controller

    commands = [
        "#!/usr/bin/env bash",
        "set -euo pipefail",
        f"vmid={vmid}",
        f"template_name={shlex.quote(template_name)}",
        f"image_url={shlex.quote(image_url)}",
        f"remote_raw_xz={shlex.quote(remote_raw_xz)}",
        f"remote_raw={shlex.quote(remote_raw)}",
        f"storage={shlex.quote(vm_storage)}",
        f"bridge={shlex.quote(bridge)}",
        "if qm config \"${vmid}\" 2>/dev/null | grep -q '^template: 1$'; then",
        "  echo 'Template already exists; skipping remote build.'",
        "  exit 0",
        "fi",
        "if qm status \"${vmid}\" >/dev/null 2>&1; then",
        "  echo 'VMID already exists but is not a template. Remove or renumber it before continuing.' >&2",
        "  exit 1",
        "fi",
        "rm -f \"${remote_raw_xz}\" \"${remote_raw}\"",
        "wget -O \"${remote_raw_xz}\" \"${image_url}\"",
        "xz -d -f \"${remote_raw_xz}\"",
        (
            "qm create \"${vmid}\" "
            f"--name {shlex.quote(template_name)} "
            f"--ostype l26 --machine {shlex.quote(machine_type)} --bios {shlex.quote(bios_type)} "
            f"--scsihw {shlex.quote(qm_scsi)} --cpu {shlex.quote(cpu_type)} "
            f"--cores {cores} --sockets {sockets} --memory {memory_mb} "
            "--net0 virtio,bridge=${bridge} --agent enabled=1 --serial0 socket --vga serial0"
        ),
        "qm importdisk \"${vmid}\" \"${remote_raw}\" \"${storage}\" --format raw",
        "imported_disk=$(qm config \"${vmid}\" | awk -F': ' '/^unused[0-9]+: / {print $2; exit}')",
        "if [ -z \"${imported_disk}\" ]; then echo 'Failed to discover imported disk.' >&2; exit 1; fi",
        "qm set \"${vmid}\" --scsi0 \"${imported_disk}\"",
        "qm set \"${vmid}\" --boot order=scsi0",
        f"qm set \"${{vmid}}\" --efidisk0 {shlex.quote(efi_disk)}",
        f"qm set \"${{vmid}}\" --description {shlex.quote(f'Talos Linux template built from Image Factory schematic {schematic_id} for {talos_version}')}",
        "qm template \"${vmid}\"",
        "rm -f \"${remote_raw}\"",
        "echo 'Talos template build completed successfully.'",
    ]
    return "\n".join(commands) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description="Build a Talos Proxmox template from Image Factory.")
    parser.add_argument("--version", required=True, help="Talos version, for example v1.12.5")
    parser.add_argument("--vmid", required=True, type=int, help="Target Proxmox VMID")
    parser.add_argument("--template-name", required=True, help="Template name to create in Proxmox")
    parser.add_argument("--schematic-file", default=str(SCHEMATIC_FILE), help="Path to the schematic YAML file")
    parser.add_argument("--memory-mb", type=int, default=2048, help="Template memory in MiB")
    parser.add_argument("--cores", type=int, default=2, help="Number of virtual CPU cores")
    parser.add_argument("--sockets", type=int, default=1, help="Number of CPU sockets")
    args = parser.parse_args()

    config = read_env_file(CONFIG_ENV)
    ssh_dir = Path.home() / ".ssh"
    ssh_key = ssh_dir / "id_ed25519"
    known_hosts = ssh_dir / "known_hosts"

    if not ssh_key.exists():
        raise FileNotFoundError(f"Required SSH key not found: {ssh_key}")

    proxmox_host_ip = config.get("PROXMOX_HOST_IP") or config.get("PROXMOX_HOST")
    proxmox_ssh_user = config.get("PROXMOX_SSH_USER", "root")
    proxmox_vm_storage = config.get("PROXMOX_VM_DATASTORE", "local-lvm")
    proxmox_bridge = config.get("PROXMOX_BRIDGE", "vmbr0")
    machine_type = config.get("PROXMOX_MACHINE_TYPE", "q35")
    bios_type = config.get("PROXMOX_BIOS_TYPE", "ovmf")
    scsi_controller = config.get("PROXMOX_SCSI_CONTROLLER", "virtio-scsi-pci")
    cpu_type = config.get("PROXMOX_CPU_TYPE", "host")

    if not proxmox_host_ip:
        raise RuntimeError("Missing PROXMOX_HOST_IP or PROXMOX_HOST in state/configs/.env")

    schematic_path = Path(args.schematic_file)
    schematic_yaml = schematic_path.read_text(encoding="utf-8")
    schematic_id = post_schematic(schematic_yaml)

    remote_script = build_remote_script(
        vmid=args.vmid,
        template_name=args.template_name,
        talos_version=args.version,
        schematic_id=schematic_id,
        vm_storage=proxmox_vm_storage,
        bridge=proxmox_bridge,
        machine_type=machine_type,
        bios_type=bios_type,
        scsi_controller=scsi_controller,
        cpu_type=cpu_type,
        memory_mb=args.memory_mb,
        cores=args.cores,
        sockets=args.sockets,
    )

    print(f"Resolved Talos schematic ID: {schematic_id}")
    result = run_ssh(proxmox_host_ip, proxmox_ssh_user, ssh_key, known_hosts, remote_script)
    if result.stdout.strip():
        print(result.stdout.strip())
    if result.stderr.strip():
        print(result.stderr.strip(), file=sys.stderr)
    if result.returncode != 0:
        print("Remote Talos template build failed. Review the SSH stderr above for the exact qm or wget error.", file=sys.stderr)
        return result.returncode
    return 0


if __name__ == "__main__":
    sys.exit(main())
