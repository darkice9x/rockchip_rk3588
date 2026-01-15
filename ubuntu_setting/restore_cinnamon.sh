#!/bin/bash

set -e

BACKUP_DIR="./cinnamon_backup_20260112_173944"

echo "========================================"
echo " Cinnamon 환경 자동 복원 (Debian/Armbian)"
echo "========================================"

# ----------------------------------------
# 1. 기본 패키지 설치
# ----------------------------------------
echo "[1/5] Cinnamon 패키지 확인..."
if ! dpkg -l | grep -q '^ii  cinnamon '; then
    echo "  - Cinnamon 설치"
    sudo apt update
    sudo apt install -y cinnamon nemo dconf-cli
else
    echo "  - Cinnamon 이미 설치됨"
fi

# ----------------------------------------
# 2. 사용자 애플릿 복원 (핵심)
# ----------------------------------------
echo "[2/5] 사용자 애플릿 복원..."

if [ -f "$BACKUP_DIR/user-applets.tar.gz" ]; then
    mkdir -p ~/.local/share/cinnamon
    tar xzvf "$BACKUP_DIR/user-applets.tar.gz" -C /
    echo "  - 사용자 애플릿 복원 완료"
else
    echo "  - ERROR: user-applets.tar.gz 없음 (이 상태로는 패널 복원 불가)"
    exit 1
fi

# ----------------------------------------
# 3. 기타 설정 파일 복원
# ----------------------------------------
echo "[3/5] 설정 파일 복원..."

if [ -f "$BACKUP_DIR/cinnamon-files.tar.gz" ]; then
    tar xzvf "$BACKUP_DIR/cinnamon-files.tar.gz" -C /
else
    echo "  - cinnamon-files.tar.gz 없음 (경고)"
fi

# ----------------------------------------
# 4. dconf 복원 (패널/애플릿 배치 담당)
# ----------------------------------------
echo "[4/5] dconf 복원..."

[ -f "$BACKUP_DIR/cinnamon.dconf" ] && dconf load /org/cinnamon/ < "$BACKUP_DIR/cinnamon.dconf"
[ -f "$BACKUP_DIR/nemo.dconf" ] && dconf load /org/nemo/ < "$BACKUP_DIR/nemo.dconf"
[ -f "$BACKUP_DIR/gnome-interface.dconf" ] && dconf load /org/gnome/desktop/interface/ < "$BACKUP_DIR/gnome-interface.dconf"

# ----------------------------------------
# 5. Cinnamon 재시작
# ----------------------------------------
echo "[5/5] Cinnamon 재시작..."

nohup cinnamon --replace >/dev/null 2>&1 &

echo "========================================"
echo " 완료. 반드시 로그아웃 → 재로그인 하십시오."
echo "========================================"
