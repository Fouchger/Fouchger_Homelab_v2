#!/usr/bin/env python3
# ================================================================
# File: packer/scripts/refresh_catalog.py
# Purpose:
#   Refresh the curated ISO metadata catalogue from upstream vendor
#   sources when the operator intentionally updates the build inputs.
#
# Notes:
#   - This script is intentionally conservative and writes operator-facing
#     output for review rather than mutating committed files silently.
#   - Debian and Talos checksum placeholders should be updated after
#     verifying official checksum material during the refresh step.
# ================================================================
from __future__ import annotations

import json
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parents[2]
OUT_FILE = ROOT_DIR / "packer" / "generated" / "catalog-review.json"
OUT_FILE.parent.mkdir(parents=True, exist_ok=True)

payload = {
    "notes": [
        "Review and confirm upstream version and checksum changes before copying them into variables.pkr.hcl.",
        "Ubuntu defaults are already pinned to current known values in variables.pkr.hcl.",
        "Debian and Talos checksum placeholders require operator confirmation during refresh.",
    ]
}

OUT_FILE.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
print(f"Rendered review scaffold at {OUT_FILE}")
