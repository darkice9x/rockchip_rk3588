#!/bin/bash
set -e

echo "==== Armbian + Cinnamon Wi-Fi Persistent Fix Script ===="

# 1. netplan 완전 제거
echo "[1/6] Removing netplan..."
if dpkg -l | grep -q netplan; then
    apt purge -y netplan.io
fi

if [ -d /etc/netplan ]; then
    mv /etc/netplan /etc/netplan.bak.$(date +%s)
fi
mkdir -p /etc/netplan

# 2. NetworkManager 설정 강제
echo "[2/6] Forcing NetworkManager configuration..."
cat > /etc/NetworkManager/NetworkManager.conf <<EOF
[main]
plugins=ifupdown,keyfile

[ifupdown]
managed=true
EOF

# 3. systemd-networkd, connman 완전 비활성화
echo "[3/6] Disabling conflicting services..."
systemctl disable --now systemd-networkd 2>/dev/null || true
systemctl disable --now connman 2>/dev/null || true

# 4. 기존 Wi-Fi 연결 제거
echo "[4/6] Cleaning old Wi-Fi connections..."
nmcli -t -f NAME,TYPE connection show | grep ':wifi' | cut -d: -f1 | while read c; do
    nmcli connection delete "$c"
done

# 5. NetworkManager 재시작
echo "[5/6] Restarting NetworkManager..."
systemctl restart NetworkManager

# 6. 상태 출력
echo "[6/6] Status check:"
echo "--------------------------------------------------"
nmcli general status
echo "--------------------------------------------------"
echo "Fix completed. Please reconnect Wi-Fi via Cinnamon UI or nmcli."
echo "Reboot after connection to verify persistence."
