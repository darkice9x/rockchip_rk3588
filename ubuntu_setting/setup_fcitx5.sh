#!/usr/bin/env bash
# Ubuntu용 fcitx5 + im-config 자동 설정 스크립트
# 작성자: ChatGPT GPT-5
# 사용법: chmod +x setup_fcitx5.sh && ./setup_fcitx5.sh

set -e

echo "🔧 fcitx5 및 관련 패키지 설치 중..."
sudo apt update
sudo apt install -y fcitx5 fcitx5-hangul fcitx5-config-qt fcitx5-frontend-gtk4 im-config

echo "⚙️ im-config로 fcitx5를 기본 입력기로 설정..."
im-config -n fcitx5

# 환경변수 추가 확인 및 설정
PROFILE_FILE="$HOME/.bashrc"
if ! grep -q "GTK_IM_MODULE=fcitx" "$PROFILE_FILE"; then
    echo "🌐 환경변수 설정 추가 중 (~/.bashrc)..."
    cat <<EOF >> "$PROFILE_FILE"

# fcitx5 input method settings
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
EOF
else
    echo "✅ ~/.bashrc에 fcitx5 환경변수가 이미 설정되어 있습니다."
fi

echo "🔄 환경변수 적용 중..."
source "$PROFILE_FILE"

echo "🚀 fcitx5 자동 실행 설정 확인 중..."
if ! pgrep -x fcitx5 >/dev/null; then
    echo "fcitx5가 실행 중이 아닙니다. 지금 실행합니다..."
    nohup fcitx5 >/dev/null 2>&1 &
else
    echo "✅ fcitx5가 이미 실행 중입니다."
fi

echo ""
echo "✅ 설치 및 설정 완료!"
echo "다음 단계:"
echo "1️⃣ 로그아웃 후 다시 로그인하세요."
echo "2️⃣ 오른쪽 상단(또는 하단)의 키보드 아이콘 클릭 → Configure"
echo "3️⃣ Hangul 추가 → Ctrl+Space로 입력기 전환"
echo "4️⃣ Chromium을 그냥 실행해보세요 (예: chromium --ozone-platform=wayland)"
echo ""
echo "🎉 이제 fcitx5로 한글 입력이 가능합니다!"
