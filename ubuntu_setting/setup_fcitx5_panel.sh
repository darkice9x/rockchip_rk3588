#!/usr/bin/env bash
# fcitx5 상태바(트레이) 자동 설정 + GNOME용 Kimpanel 자동 설치
# 작성자: ChatGPT GPT-5
# 사용법: chmod +x setup_fcitx5_panel.sh && ./setup_fcitx5_panel.sh

set -e

echo "🔧 [1/6] fcitx5 UI 및 패널 관련 패키지 설치 중..."
sudo apt update
sudo apt install -y fcitx5-ui-classic fcitx5-material-color fcitx5-frontend-gtk4 \
                    fcitx5-frontend-gtk3 fcitx5-frontend-qt5 fcitx5-gtk fcitx5-qt \
                    fcitx5-module-dbus fcitx5-module-wayland fcitx5-config-qt dbus-x11

echo ""
echo "🔍 [2/6] 현재 데스크톱 환경 감지 중..."
DE=$(echo "$XDG_CURRENT_DESKTOP" | tr '[:upper:]' '[:lower:]')

if [[ "$DE" == *"gnome"* ]]; then
    echo "🧠 GNOME 환경이 감지되었습니다."
    echo "GNOME에서는 기본적으로 fcitx5 트레이 아이콘이 표시되지 않습니다."
    echo "💡 Kimpanel 확장 자동 설치를 진행합니다."

    echo ""
    echo "🔧 [2.1] gnome-shell-extension-manager 및 커넥터 설치 중..."
    sudo apt install -y gnome-shell-extension-manager gnome-shell-extension-prefs gnome-shell-extensions chrome-gnome-shell

    echo ""
    echo "🔽 [2.2] Kimpanel 확장 설치 시도 중..."
    EXT_ID=261
    EXT_UUID="kimpanel@kde.org"
    EXT_URL="https://extensions.gnome.org/extension/${EXT_ID}/kimpanel/"

    if command -v gnome-extensions-cli >/dev/null 2>&1; then
        echo "gnome-extensions-cli 감지됨 → CLI 방식으로 설치합니다."
        gnome-extensions-cli install "$EXT_ID" || true
    else
        echo "⚠️ gnome-extensions-cli가 없습니다."
        echo "웹에서 직접 설치해야 할 수도 있습니다."
        echo "🔗 아래 링크를 열고 'Install' 클릭:"
        echo "$EXT_URL"
    fi

    echo ""
    echo "🧠 [2.3] 확장 활성화 중..."
    gnome-extensions enable "$EXT_UUID" || true

    echo ""
    echo "✅ Kimpanel 확장 설치 완료!"
    echo "⚡ GNOME Shell 재시작 필요 (Alt + F2 → r → Enter 또는 로그아웃 후 재로그인)"
elif [[ "$DE" == *"plasma"* ]]; then
    echo "💠 KDE Plasma 환경 감지됨 → fcitx5 트레이 자동 표시."
elif [[ "$DE" == *"xfce"* ]]; then
    echo "🧩 Xfce 환경 감지됨 → 'Status Tray Plugin' 패널에 추가되어야 함."
elif [[ "$DE" == *"lxqt"* ]]; then
    echo "💡 LXQt 환경 감지됨 → fcitx5 아이콘 자동 표시됨."
else
    echo "⚠️ 알 수 없는 데스크톱 환경입니다. (XDG_CURRENT_DESKTOP=$XDG_CURRENT_DESKTOP)"
    echo "fcitx5-ui-classic이 기본으로 상태바를 표시할 것입니다."
fi

echo ""
echo "🎨 [3/6] fcitx5 classic UI 설정 중..."
CONFIG_DIR="$HOME/.config/fcitx5/conf"
mkdir -p "$CONFIG_DIR"

CLASSIC_CONF="$CONFIG_DIR/classicui.conf"
cat <<EOF > "$CLASSIC_CONF"
Vertical Candidate List=False
Font="Noto Sans CJK KR 11"
Theme=Default
ShowInputMethodInformation=True
ShowInputMethodIconInTray=True
PreferTextIcon=False
UsePerScreenDPI=True
EOF

echo "✅ classic UI 설정 완료: $CLASSIC_CONF"

echo ""
echo "🚀 [4/6] fcitx5 재시작 중..."
pkill fcitx5 || true
nohup fcitx5 >/dev/null 2>&1 &
sleep 2

echo ""
echo "🧩 [5/6] 입력기 환경 설정 적용 중..."
im-config -n fcitx5

echo ""
echo "🧠 [6/6] 확인:"
echo " - fcitx5 트레이 아이콘(A/가)이 상태바에 표시되어야 합니다."
echo " - 안 보일 경우: fcitx5-config-qt → Addons → Classic UI 활성화 확인"
echo ""
echo "✅ 완료되었습니다!"
echo "이제 한/영 전환(Ctrl + Space) 시 상태바에서 A ↔ 가 아이콘이 표시됩니다."
