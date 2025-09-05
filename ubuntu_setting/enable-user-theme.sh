#!/bin/bash
set -e

echo "[1/4] gnome-shell-extensions 설치..."
sudo apt update
sudo apt install -y gnome-shell-extensions

echo "[2/4] user-theme 확장 ID 확인..."
EXTENSION_ID="user-theme@gnome-shell-extensions.gcampax.github.com"

echo "[3/4] 현재 활성화된 확장 목록 가져오기..."
CURRENT=$(gsettings get org.gnome.shell enabled-extensions)

# 확장이 이미 포함되어 있는지 확인
if echo "$CURRENT" | grep -q "$EXTENSION_ID"; then
    echo "이미 User Theme 확장이 활성화되어 있습니다."
else
    echo "[4/4] 확장 활성화 중..."
    # 배열에 user-theme 추가
    NEW=$(echo "$CURRENT" | sed "s/]$/, '$EXTENSION_ID']/")
    gsettings set org.gnome.shell enabled-extensions "$NEW"
    echo "User Theme 확장을 활성화했습니다."
fi

echo "완료 ✅"
echo "GNOME Shell을 재시작해야 합니다 (Xorg에서는 Alt+F2 → r, Wayland는 로그아웃 후 재로그인)."
