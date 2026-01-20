#!/usr/bin/env bash
set -e

#ZRAM 확장 16G로
# 백업 생성
sudo cp "/etc/default/armbian-zram-config" "/etc/default/armbian-zram-config.bak"

# ZRAM_PERCENTAGE 변경
sudo sed -i 's/^#\s*ZRAM_PERCENTAGE=50/ZRAM_PERCENTAGE=100/' "/etc/default/armbian-zram-config"

# SWAP 생성
SWAPFILE_MB=8192
sudo fallocate -l ${SWAPFILE_MB}M /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile

# Ensure fstab entry exists once
sudo grep -q "^/swapfile" /etc/fstab || \
echo "/swapfile none swap sw,pri=10 0 0" >> /etc/fstab
sudo swapon /swapfile

echo "수정 완료 ✅"
echo "백업 파일: /etc/default/armbian-zram-config.bak"
