#!/bin/bash

# Zsh 및 필수 패키지 설치
sudo apt update
sudo apt install -y zsh git curl wget

# Zsh 설치 확인
if ! command -v zsh &> /dev/null; then
    echo "❌ zsh 설치 실패"
    exit 1
fi

# oh-my-zsh 설치
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "📦 oh-my-zsh 설치 중..."
    RUNZSH=no KEEP_ZSHRC=yes sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

# powerlevel10k 테마 설치
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    echo "🎨 powerlevel10k 테마 설치 중..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
        "$ZSH_CUSTOM/themes/powerlevel10k"
fi

# autosuggestions 플러그인 설치
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "🔍 zsh-autosuggestions 설치 중..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# syntax-highlighting 플러그인 설치
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "🌈 zsh-syntax-highlighting 설치 중..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# .zshrc 설정 변경
ZSHRC="$HOME/.zshrc"

# 테마 변경
sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$ZSHRC"

# 플러그인 라인 변경
if grep -q '^plugins=(' "$ZSHRC"; then
    sed -i 's/^plugins=(.*)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$ZSHRC"
else
    echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' >> "$ZSHRC"
fi

# MesloLGS NF Regular 폰트 설치
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
FONT_URL="https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"
FONT_PATH="$FONT_DIR/MesloLGS NF Regular.ttf"

if [ ! -f "$FONT_PATH" ]; then
    echo "🔤 MesloLGS NF Regular 폰트 다운로드 중..."
    wget -O "$FONT_PATH" "$FONT_URL"
    echo "📦 폰트 캐시 갱신 중..."
    fc-cache -f "$FONT_DIR"
fi

# zsh를 기본 쉘로 설정
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "🛠️ 기본 쉘을 zsh로 변경 중..."
    chsh -s "$(which zsh)"
fi

echo ""
echo "✅ 설치 완료!"
echo "1️⃣ 터미널을 재시작하거나 'zsh' 입력"
echo "2️⃣ Powerlevel10k 설정 마법사 실행"
echo "3️⃣ 터미널에서 폰트 설정을 'MesloLGS NF Regular'로 변경하세요 (필수!)"
