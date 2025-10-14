#!/bin/bash
#영문에서 한글로 변환
#!/bin/bash
#
# toggle_user_dirs_lang.sh
# 사용자 홈 디렉토리 이름을 영문(C) <-> 한글(ko_KR)로 전환하는 자동 스크립트
# GNOME, Cinnamon, XFCE, Armbian 등 모든 환경에서 작동
#

CONFIG_DIR="$HOME/.config"
LOCALE_FILE="$CONFIG_DIR/user-dirs.locale"
DIRS_FILE="$CONFIG_DIR/user-dirs.dirs"

# 현재 상태 확인
CURRENT_LANG=$(cat "$LOCALE_FILE" 2>/dev/null || echo "C")

# xdg-user-dirs 확인
if ! command -v xdg-user-dirs-update >/dev/null 2>&1; then
    echo "⚠️  xdg-user-dirs 패키지가 설치되어 있지 않습니다."
    echo "    설치 명령: sudo apt install xdg-user-dirs"
    exit 1
fi

# DBus 세션 자동 생성
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval $(dbus-launch --sh-syntax 2>/dev/null)
    if [ -n "$DBUS_SESSION_BUS_ADDRESS" ]; then
        echo "🔧 DBus 세션 자동 생성됨."
    else
        echo "⚠️ DBus 세션을 생성하지 못했습니다. (CLI 환경일 가능성 있음)"
    fi
fi

# DISPLAY 환경 확인
if [ -z "$DISPLAY" ]; then
    # X 세션이 없으면 CLI 환경으로 간주
    XDG_CMD="xdg-user-dirs-update"
else
    # DISPLAY가 있고 GTK 명령이 존재하면 GTK 버전 사용
    if command -v xdg-user-dirs-gtk-update >/dev/null 2>&1; then
        XDG_CMD="xdg-user-dirs-gtk-update"
    else
        XDG_CMD="xdg-user-dirs-update"
    fi
fi

# 언어 전환 함수
switch_to_korean() {
    echo "🇰🇷 한글 디렉토리로 전환 중..."
    export LANG=ko_KR.UTF-8
    echo "ko_KR" > "$LOCALE_FILE"
    $XDG_CMD
    echo "✅ 한글 디렉토리로 갱신 완료."
}

switch_to_english() {
    echo "🇺🇸 영문 디렉토리로 전환 중..."
    export LANG=C
    echo "C" > "$LOCALE_FILE"
    $XDG_CMD
    echo "✅ 영문 디렉토리로 갱신 완료."
}

# 실행 로직
echo "현재 user-dirs.locale: $CURRENT_LANG"
if [[ "$CURRENT_LANG" == "ko_KR" ]]; then
    switch_to_english
else
    switch_to_korean
fi

# 결과 표시
echo
echo "📂 현재 사용자 디렉토리 설정:"
grep XDG_ "$DIRS_FILE"
echo
echo "완료되었습니다 🎉"


sudo locale-gen ko_KR.UTF-8
sudo dpkg-reconfigure locales
sudo -u gdm dbus-launch gsettings set org.gnome.system.locale region 'ko_KR.UTF-8'
sudo update-locale LANG=ko_KR.UTF-8 LC_ALL=ko_KR.UTF-8

sudo cp /home/darkice/ExtUSB/Backup/Apps\ Install/open-as-root.nemo_action /usr/share/nemo/actions
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false

#/etc/gdm3/custom.conf 파일에 내용 작성
cat << EOF | sudo tee /etc/gdm3/custom.conf > /dev/null
[daemon]
	AutomaticLoginEnable = false
	AutomaticLogin = darkice
EOF

sudo cp ~/.config/monitors.xml /var/lib/gdm3/.config/monitors.xml

#docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.36.2/docker-compose-linux-aarch64" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
