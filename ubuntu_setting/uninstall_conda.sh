#!/bin/bash

echo "=== Miniconda FULL CLEAN (SAFE MODE) START ==="

# 1. conda 관련 프로세스만 종료 (정확 매칭)
pgrep -af conda
pkill -f "/miniconda3"
pkill -f "conda"

# 2. 설치 디렉토리 제거
echo "[*] Removing ~/miniconda3 ..."
rm -rf ~/miniconda3

# 3. 설정 디렉토리 제거
echo "[*] Removing conda config dirs ..."
rm -rf ~/.conda ~/.continuum ~/.cache/conda ~/.config/conda

# 4. 쉘 설정 파일 정리
for f in ~/.bashrc ~/.zshrc ~/.profile ~/.zprofile; do
    if [ -f "$f" ]; then
        echo "[*] Cleaning $f"
        sed -i '/conda initialize/,+20d' "$f"
        sed -i '/miniconda3/d' "$f"
        sed -i '/anaconda/d' "$f"
    fi
done

echo "=== DONE. Close terminal and reopen. ==="
