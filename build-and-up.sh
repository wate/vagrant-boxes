#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

echo "[1/4] Validating templates..."
packer validate debian-13.pkr.hcl
vagrant validate

echo "[2/4] Building box with Packer..."
packer build -force debian-13.pkr.hcl

echo "[3/4] Recreating VM from updated box..."
vagrant destroy -f || true

# Shared folder mount and Guest Additions state are verified as part of boot.
echo "[4/4] Booting VM with Vagrant..."
vagrant up

echo "Done: packer build and vagrant up completed successfully."
