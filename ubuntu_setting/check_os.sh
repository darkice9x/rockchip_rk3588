#!/bin/bash

OS_RELEASE_FILE="/etc/os-release"

if [ ! -f "$OS_RELEASE_FILE" ]; then
    echo "ERROR: /etc/os-release 파일이 존재하지 않습니다."
    exit 1
fi

# source로 변수 로드
. "$OS_RELEASE_FILE"

echo "=== OS Information ==="
echo "NAME        : $NAME"
echo "VERSION     : $VERSION"
echo "ID          : $ID"
echo "ID_LIKE     : $ID_LIKE"
echo "VERSION_ID  : $VERSION_ID"
echo "CODENAME    : ${VERSION_CODENAME:-N/A}"
echo "======================"

echo

case "$ID" in
    ubuntu)
        echo "판별 결과: Ubuntu 계열입니다."
        ;;
    debian)
        echo "판별 결과: Debian 계열입니다."
        ;;
    *)
        echo "판별 결과: 기타 배포판 ($ID) 입니다."
        ;;
esac

# 배포판 판별 (if문)
if [ "$ID" = "ubuntu" ]; then
    echo "판별 결과: Ubuntu 계열입니다."
elif [ "$ID" = "debian" ]; then
    echo "판별 결과: Debian 계열입니다."
else
    echo "판별 결과: 기타 배포판 ($ID) 입니다."
fi

# Armbian 추가 판별
if [ -f /etc/armbian-release ]; then
    echo
    echo "※ Armbian 환경 감지됨"
    cat /etc/armbian-release
fi
