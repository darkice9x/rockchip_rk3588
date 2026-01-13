#!/usr/bin/env bash
# Ubuntu용 fcitx5 + Hangul + im-config 자동 설정 스크립트 (완전 자동 버전)
# 작성자: ChatGPT GPT-5
# 사용법: chmod +x setup_fcitx5_full.sh && ./setup_fcitx5_full.sh

set -e

OS_RELEASE_FILE="/etc/os-release"

if [ ! -f "$OS_RELEASE_FILE" ]; then
    echo "ERROR: /etc/os-release 파일이 존재하지 않습니다."
    exit 1
fi

# source로 변수 로드
. "$OS_RELEASE_FILE"

echo "🔧 [1/6] fcitx5 및 관련 패키지 설치 중..."
sudo apt update
if [ "$ID" = "ubuntu" ]; then
    echo "판별 결과: Ubuntu 계열입니다."
	sudo apt install -y language-pack-ko language-pack-ko-base language-selector-common language-selector-gnome language-pack-gnome-ko language-pack-gnome-ko-base
elif [ "$ID" = "debian" ]; then
	sudo apt install -y fcitx5 fcitx5-hangul fcitx5-config-qt im-config dbus-x11 
	if [ "$DESKTOP_SESSION" = "cinnamon" ]; then
		sudo apt install -y fcitx5-frontend-gtk3
	else
		sudo apt install -y fcitx5-frontend-gtk4
	fi
fi
sudo apt install -y fonts-nanum fonts-nanum-coding fonts-noto-cjk fonts-unfonts-core fonts-unfonts-extra

echo "⚙️ [2/6] im-config로 fcitx5를 기본 입력기로 설정..."
im-config -n fcitx5

# 환경변수 추가
PROFILE_FILE="$HOME/.bashrc"
if ! grep -q "GTK_IM_MODULE=fcitx" "$PROFILE_FILE"; then
    echo "🌐 [3/6] ~/.bashrc에 fcitx5 환경변수 추가 중..."
    cat <<EOF >> "$PROFILE_FILE"

# fcitx5 input method environment variables
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
EOF
else
    echo "✅ ~/.bashrc에 fcitx5 환경변수가 이미 설정되어 있습니다."
fi

source "$PROFILE_FILE"

# fcitx5 autostart 설정
AUTOSTART_DIR="$HOME/.config/autostart"
mkdir -p "$AUTOSTART_DIR"

AUTOSTART_FILE="$AUTOSTART_DIR/fcitx5.desktop"
if [ ! -f "$AUTOSTART_FILE" ]; then
    echo "🚀 [4/6] fcitx5 자동 실행 설정 추가..."
    cat <<EOF > "$AUTOSTART_FILE"
[Desktop Entry]
Type=Application
Exec=fcitx5
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Fcitx5
Comment=Start Fcitx5 input method
EOF
else
    echo "✅ fcitx5 자동 실행 설정이 이미 있습니다."
fi

# fcitx5 실행
echo "▶️ [5/6] fcitx5 실행 확인..."
if ! pgrep -x fcitx5 >/dev/null; then
    echo "fcitx5가 실행 중이 아닙니다. 지금 실행합니다..."
    nohup fcitx5 >/dev/null 2>&1 &
else
    echo "✅ fcitx5가 이미 실행 중입니다."
fi

# Hangul 입력기 자동 추가
echo "🇰🇷 [6/6] Hangul 입력기 자동 등록 중..."

# fcitx5가 DBus를 통해 접근 가능해야 하므로 잠시 대기
sleep 2

# fcitx5를 통한 자동 입력기 추가 명령
if command -v fcitx5-remote >/dev/null; then
    # fcitx5 설정 파일 위치
    CONFIG_DIR="$HOME/.config/fcitx5"
    PROFILE_FILE2="$CONFIG_DIR/profile"
    mkdir -p "$CONFIG_DIR"

    # 이미 Hangul이 설정돼 있는지 확인
    if ! grep -q "Hangul" "$PROFILE_FILE2" 2>/dev/null; then
        echo "InputMethod/Hangul" >> "$PROFILE_FILE2"
        echo "✅ Hangul 입력기가 자동으로 등록되었습니다."
    else
        echo "✅ Hangul 입력기가 이미 설정되어 있습니다."
    fi
else
    echo "⚠️ fcitx5-remote를 찾을 수 없습니다. Hangul은 수동으로 추가해야 할 수 있습니다."
fi

echo ""
echo "🎉 모든 설정이 완료되었습니다!"
echo ""
echo "다음 단계:"
echo "1️⃣ 로그아웃 후 다시 로그인하세요."
echo "2️⃣ 오른쪽 상단(또는 하단)의 키보드 아이콘 클릭 → Configure"
echo "3️⃣ 'Hangul'이 등록되어 있으면 Ctrl+Space로 한/영 전환 가능"
echo "4️⃣ 이제 chromium을 그냥 실행해보세요 (예: chromium --ozone-platform=wayland)"
echo ""
echo "✅ fcitx5 + Hangul 입력기가 완전히 설정되었습니다!"
