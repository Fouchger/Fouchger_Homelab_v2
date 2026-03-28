#!/usr/bin/env python3
# ================================================================
# File: packer/scripts/render_template_vars.py
# Purpose:
#   Render Terraform-consumable template identifiers from the curated
#   Packer VMID and naming model.
# ================================================================
from __future__ import annotations

import json
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parents[2]
OUT_DIR = ROOT_DIR / "packer" / "generated"
OUT_DIR.mkdir(parents=True, exist_ok=True)

payload = {
    "template_catalog": {
        "ubuntu_22": {"name": "tpl-ubuntu-22", "vmid": 24001},
        "ubuntu_24": {"name": "tpl-ubuntu-24", "vmid": 24002},
        "debian_12": {"name": "tpl-debian-12", "vmid": 24021},
        "debian_13": {"name": "tpl-debian-13", "vmid": 24022},
        "talos_1_12_4": {"name": "tpl-talos-1-12-4", "vmid": 24041},
        "talos_1_12_5": {"name": "tpl-talos-1-12-5", "vmid": 24042},
    }
}

with (OUT_DIR / "templates.auto.tfvars.json").open("w", encoding="utf-8") as handle:
    json.dump(payload, handle, indent=2)
    handle.write("\n")

with (OUT_DIR / "vmids.auto.pkrvars.hcl").open("w", encoding="utf-8") as handle:
    handle.write(
        "# ================================================================\n"
        "# File: packer/generated/vmids.auto.pkrvars.hcl\n"
        "# Purpose:\n"
        "#   Shared VMID assignments for the curated Packer template catalogue.\n"
        "# ================================================================\n"
        "ubuntu_22_vmid = 24001\n"
        "ubuntu_24_vmid = 24002\n"
        "debian_12_vmid = 24021\n"
        "debian_13_vmid = 24022\n"
        "talos_1_12_4_vmid = 24041\n"
        "talos_1_12_5_vmid = 24042\n"
    )

print(f"Rendered {OUT_DIR / 'templates.auto.tfvars.json'}")
print(f"Rendered {OUT_DIR / 'vmids.auto.pkrvars.hcl'}")
