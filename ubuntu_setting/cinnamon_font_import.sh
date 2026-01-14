#!/usr/bin/env bash

IN_FILE="./gnome_font_profile.conf"

if [ ! -f "$IN_FILE" ]; then
  echo "설정 파일이 없습니다: $IN_FILE"
  exit 1
fi

source "$IN_FILE"

echo "=== GNOME 폰트 환경 → Cinnamon 적용 ==="

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

echo "완료. 로그아웃 또는 cinnamon --replace 권장"
