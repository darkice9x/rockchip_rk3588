#!/bin/bash

set -e

echo ">> Cleaning netplan and keeping only NetworkManager renderer"

BACKUP_DIR="/etc/netplan.backup.$(date +%Y%m%d_%H%M%S)"

echo ">> Backup existing netplan to $BACKUP_DIR"
sudo mkdir -p "$BACKUP_DIR"
sudo cp -a /etc/netplan/* "$BACKUP_DIR/" || true

echo ">> Removing all existing netplan yaml files"
sudo rm -f /etc/netplan/*.yaml

echo ">> Creating clean 01-networkmanager.yaml"

sudo tee /etc/netplan/01-networkmanager.yaml > /dev/null <<EOF
network:
  version: 2
  renderer: NetworkManager
EOF

echo ">> Applying netplan"
sudo netplan generate
sudo netplan apply

echo ">> Done. systemd-networkd should remain inactive, NetworkManager active."
