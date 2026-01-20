#!/usr/bin/env bash
set -e

# ==========================================
# LightDM Greeter Full Reset & Reconfigure
# Target: Armbian / Ubuntu / Cinnamon
# ==========================================

if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root."
  exit 1
fi

echo "========================================="
echo " LightDM Greeter Full Reset Script"
echo "========================================="

echo
echo "[STEP 1] Detect current greeter configuration"
echo "-----------------------------------------"

echo "Active greeter-session entries:"
grep -R "greeter-session" /etc/lightdm /usr/share/lightdm 2>/dev/null || echo "  (none)"

echo
echo "Installed greeter packages:"
dpkg -l | grep -E "greeter|lightdm" | grep ii || true

echo
echo "[STEP 2] Stop LightDM"
echo "-----------------------------------------"
systemctl stop lightdm || true

echo
echo "[STEP 3] Remove ALL greeter configuration overrides"
echo "-----------------------------------------"

# 백업 디렉터리
BACKUP_DIR="/root/lightdm-greeter-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# /etc/lightdm 설정 백업 및 제거
if [ -d /etc/lightdm ]; then
  cp -a /etc/lightdm "$BACKUP_DIR/"
  rm -rf /etc/lightdm/*
fi

# /usr/share/lightdm greeter 관련 conf 비활성화
if [ -d /usr/share/lightdm/lightdm.conf.d ]; then
  mkdir -p "$BACKUP_DIR/usr-share-lightdm"
  cp -a /usr/share/lightdm/lightdm.conf.d "$BACKUP_DIR/usr-share-lightdm/"
  find /usr/share/lightdm/lightdm.conf.d -type f \
    -name "*greeter*" -o -name "*gtk*" -o -name "*wrapper*" \
    | while read -r f; do
        mv "$f" "$f.disabled"
      done
fi

echo "Backup stored at: $BACKUP_DIR"

echo
echo "[STEP 4] Remove autologin settings (global)"
echo "-----------------------------------------"

# 혹시 남아 있을 수 있는 autologin 제거
find /etc /usr/share -type f -name "*.conf" 2>/dev/null \
  | xargs grep -l "autologin-user" 2>/dev/null \
  | while read -r f; do
      sed -i 's/^autologin-user/# autologin-user/' "$f"
    done

echo
echo "[STEP 5] Clean LightDM runtime & state files"
echo "-----------------------------------------"

rm -rf /var/run/lightdm/*
rm -f /var/lib/lightdm/.Xauthority
chown -R lightdm:lightdm /var/lib/lightdm 2>/dev/null || true

echo
echo "[STEP 6] Ensure slick-greeter is installed"
echo "-----------------------------------------"

apt update
apt install -y lightdm slick-greeter

echo
echo "[STEP 7] Recreate clean LightDM configuration"
echo "-----------------------------------------"

mkdir -p /etc/lightdm/lightdm.conf.d

cat >/etc/lightdm/lightdm.conf.d/00-greeter.conf <<'EOF'
[Seat:*]
greeter-session=slick-greeter
EOF

cat >/etc/lightdm/slick-greeter.conf <<'EOF'
[Greeter]
background=#000000
draw-user-backgrounds=false
draw-grid=false
EOF

echo
echo "[STEP 8] Ensure LightDM is the active display manager"
echo "-----------------------------------------"
echo /usr/sbin/lightdm >/etc/X11/default-display-manager

echo
echo "[STEP 9] Start LightDM"
echo "-----------------------------------------"
systemctl start lightdm

echo
echo "========================================="
echo " Greeter reset complete"
echo " Reboot strongly recommended"
echo "========================================="
