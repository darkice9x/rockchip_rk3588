#!/bin/bash

set -e

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="./cinnamon_backup_$TIMESTAMP"

echo "========================================"
echo " Cinnamon 환경 전체 백업 시작"
echo " 대상: Debian / Armbian (UUID 애플릿 구조)"
echo " 백업 위치: $BACKUP_DIR"
echo "========================================"

mkdir -p "$BACKUP_DIR"

# ----------------------------------------
# 1. dconf 백업 (패널 / 애플릿 배치 / 단축키 / UI 핵심)
# ----------------------------------------
echo "[1/5] dconf 설정 백업..."

dconf dump /org/cinnamon/ > "$BACKUP_DIR/cinnamon.dconf"
dconf dump /org/nemo/ > "$BACKUP_DIR/nemo.dconf"
dconf dump /org/gnome/desktop/interface/ > "$BACKUP_DIR/gnome-interface.dconf"

echo "  - dconf 백업 완료"

# ----------------------------------------
# 2. 사용자 애플릿 백업 (핵심)
# ----------------------------------------
echo "[2/5] 사용자 애플릿 백업..."

if [ -d "$HOME/.local/share/cinnamon/applets" ]; then
    tar czvf "$BACKUP_DIR/user-applets.tar.gz" "$HOME/.local/share/cinnamon/applets"
    echo "  - user-applets.tar.gz 생성 완료"
else
    echo "  - WARNING: ~/.local/share/cinnamon/applets 디렉터리가 없습니다."
fi

# ----------------------------------------
# 3. Cinnamon 관련 설정 파일 백업
# ----------------------------------------
echo "[3/5] Cinnamon 설정 파일 백업..."

tar czvf "$BACKUP_DIR/cinnamon-files.tar.gz" \
    "$HOME/.cinnamon" \
    "$HOME/.config/cinnamon" \
    "$HOME/.local/share/cinnamon/themes" \
    "$HOME/.local/share/cinnamon/extensions" \
    "$HOME/.themes" \
    "$HOME/.icons" \
    "$HOME/.local/share/themes" \
    2>/dev/null || true

echo "  - 설정 파일 백업 완료"

# ----------------------------------------
# 4. 모니터 설정 분리 백업 (같은 PC 재설치용)
# ----------------------------------------
echo "[4/5] 모니터 설정 백업..."

MONITOR_FILE="$HOME/.config/cinnamon-monitors.xml"
if [ -f "$MONITOR_FILE" ]; then
    cp "$MONITOR_FILE" "$BACKUP_DIR/cinnamon-monitors.xml"
    echo "  - cinnamon-monitors.xml 백업 완료"
else
    echo "  - 모니터 설정 파일 없음 (스킵)"
fi

# ----------------------------------------
# 5. 검증 출력
# ----------------------------------------
echo "[5/5] 백업 검증..."

echo "----------------------------------------"
ls -lh "$BACKUP_DIR"
echo "----------------------------------------"

echo "========================================"
echo " 백업 완료"
echo " 디렉터리: $BACKUP_DIR"
echo "========================================"
