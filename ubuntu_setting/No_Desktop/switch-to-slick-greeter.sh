#!/usr/bin/env bash
set -e

# ================================
# LightDM → slick-greeter 전환 스크립트
# Target: Armbian / Ubuntu / Cinnamon
# ================================

if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root."
  exit 1
fi

echo "========================================"
echo " LightDM slick-greeter 안정화 전환 시작 "
echo "========================================"

# 1. 필수 패키지 설치
echo "[1/6] Installing slick-greeter..."
apt update
apt install -y slick-greeter lightdm

# 2. 기존 greeter 설정 정리
echo "[2/6] Cleaning old greeter configuration..."

mkdir -p /etc/lightdm/lightdm.conf.d

# 기존 greeter-session 비활성화
if [ -f /etc/lightdm/lightdm.conf ]; then
  sed -i 's/^greeter-session=.*/# &/' /etc/lightdm/lightdm.conf || true
  sed -i 's/^autologin-user=.*/# &/' /etc/lightdm/lightdm.conf || true
fi

# drop-in 설정에서도 autologin 제거
grep -RIl "autologin-user" /etc/lightdm/lightdm.conf.d 2>/dev/null | while read -r f; do
  sed -i 's/^autologin-user=.*/# &/' "$f"
done

# 3. slick-greeter 전용 설정 생성
echo "[3/6] Writing slick-greeter config..."

cat >/etc/lightdm/lightdm.conf.d/50-slick-greeter.conf <<'EOF'
[Seat:*]
greeter-session=slick-greeter
EOF

# 4. LightDM 권한/잔여 파일 정리 (중요)
echo "[4/6] Cleaning LightDM runtime files..."

rm -f /var/lib/lightdm/.Xauthority
rm -rf /var/run/lightdm/*

chown -R lightdm:lightdm /var/lib/lightdm || true

# 5. slick-greeter 기본 설정 보정 (안정성)
echo "[5/6] Ensuring slick-greeter defaults..."

mkdir -p /etc/lightdm/slick-greeter.conf.d

cat >/etc/lightdm/slick-greeter.conf.d/01-defaults.conf <<'EOF'
[Greeter]
background=#000000
draw-user-backgrounds=false
draw-grid=false
EOF

# 6. LightDM 재시작
echo "[6/6] Restarting LightDM..."
systemctl restart lightdm

echo "========================================"
echo " slick-greeter 전환 완료"
echo " 재부팅 후 로그인 화면이 표시됩니다."
echo "========================================"
