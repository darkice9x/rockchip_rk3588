#!/usr/bin/env bash
set -e

PPA="ppa:liujianfeng1994/rockchip-multimedia"

echo "======================================"
echo " Add Rockchip Multimedia PPA"
echo "======================================"

# 1. 필수 패키지 설치
if ! command -v add-apt-repository >/dev/null 2>&1; then
    echo "[INFO] software-properties-common 설치 중..."
    sudo apt update
    sudo apt install -y software-properties-common
fi

# 2. PPA 추가 (비대화형)
echo "[INFO] PPA 추가: ${PPA}"
sudo add-apt-repository -y "${PPA}"

# 3. 패키지 목록 갱신
echo "[INFO] apt update 실행"
sudo apt update

echo "[OK] PPA 추가 및 업데이트 완료"
