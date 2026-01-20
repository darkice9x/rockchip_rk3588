#!/bin/bash

set -e

BACKUP_DIR="./cinnamon_backup_20260120_220218"

echo "========================================"
echo " Cinnamon 환경 자동 복원 (Debian/Armbian)"
echo "========================================"

# ----------------------------------------
# 1. 기본 패키지 설치
# ----------------------------------------
echo "[1/9] Cinnamon 패키지 확인..."
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
echo "[2/9] 사용자 애플릿 복원..."

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
echo "[3/9] 설정 파일 복원..."

if [ -f "$BACKUP_DIR/cinnamon-files.tar.gz" ]; then
    tar xzvf "$BACKUP_DIR/cinnamon-files.tar.gz" -C /
else
    echo "  - cinnamon-files.tar.gz 없음 (경고)"
fi

# ----------------------------------------
# 4. dconf 복원 (패널/애플릿 배치 담당)
# ----------------------------------------
echo "[4/9] dconf 복원..."

[ -f "$BACKUP_DIR/cinnamon.dconf" ] && dconf load /org/cinnamon/ < "$BACKUP_DIR/cinnamon.dconf"
[ -f "$BACKUP_DIR/nemo.dconf" ] && dconf load /org/nemo/ < "$BACKUP_DIR/nemo.dconf"
[ -f "$BACKUP_DIR/gnome-interface.dconf" ] && dconf load /org/gnome/desktop/interface/ < "$BACKUP_DIR/gnome-interface.dconf"

IN_FILE="./gnome_font_profile.conf"

if [ ! -f "$IN_FILE" ]; then
  echo "설정 파일이 없습니다: $IN_FILE"
  exit 1
fi

# ----------------------------------------
# 5. 폰트 세팅
# ----------------------------------------
source "$IN_FILE"

echo "[5/9] GNOME 폰트 환경 → Cinnamon 적용 "

gsettings set org.cinnamon.desktop.interface font-name "$FONT_UI"
gsettings set org.gnome.desktop.interface document-font-name "$FONT_DOC"
gsettings set org.gnome.desktop.interface monospace-font-name "$FONT_MONO"
gsettings set org.cinnamon.desktop.wm.preferences titlebar-font "$FONT_TITLE"

gsettings set org.gnome.desktop.interface font-hinting "$HINTING"
gsettings set org.gnome.desktop.interface font-antialiasing "$ANTIALIAS"
gsettings set org.gnome.desktop.interface font-rgba-order "$RGBA"

#gsettings set org.cinnamon.desktop.interface scaling-factor "$SCALING"
gsettings set org.cinnamon.desktop.interface text-scaling-factor "$TEXT_SCALING"

rm -rf ~/.cache/fontconfig
fc-cache -rv

# ----------------------------------------
# 6. 바탕화면 세팅
# ----------------------------------------
echo "[6/9] 바탕화면 세팅적용 "
mkdir -p $HOME/.local/share/wallpaper
cp $HOME/ExtUSB/Backup/Wallpaper/SpaceFun.png $HOME/.local/share/wallpaper/
sudo cp $HOME/ExtUSB/Backup/Wallpaper/SpaceFun.png /usr/share/backgrounds/
WALLPAPER_FILE="/usr/share/backgrounds/SpaceFun.png"
gsettings set org.cinnamon.desktop.background picture-uri "file://$WALLPAPER_FILE"
gsettings set org.cinnamon.desktop.background picture-options 'zoom'

# ----------------------------------------
# 7. 이벤트 세팅
# ----------------------------------------
echo "[7/9] 사운드 이벤트 가능 "
gsettings set org.cinnamon.sounds login-enabled true
gsettings set org.cinnamon.sounds logout-enabled true
gsettings set org.cinnamon.sounds switch-enabled true
gsettings set org.cinnamon.desktop.sound event-sounds true

# ----------------------------------------
# 8. greeter 세팅
# ----------------------------------------
echo "[8/9] greeter 세팅 "
sudo tee /etc/lightdm/lightdm-gtk-greeter.conf > /dev/null << 'EOF'
[greeter]
background = /usr/share/backgrounds/SpaceFun.png
theme-name = WhiteSur-Dark
icon-theme-name = WhiteSur-dark
EOF

# ----------------------------------------
# 9. Cinnamon 재시작
# ----------------------------------------
echo "[9/9] Cinnamon 재시작..."

nohup cinnamon --replace >/dev/null 2>&1 &

echo "========================================"
echo " 완료. 반드시 로그아웃 → 재로그인 하십시오."
echo "========================================"
