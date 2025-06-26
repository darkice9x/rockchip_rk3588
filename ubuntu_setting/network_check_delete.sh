#!/bin/bash

echo "🔧 타이머 중지 및 비활성화"
sudo systemctl disable --now check-nmcli-connectivity.timer
sudo systemctl disable --now check-nmcli-connectivity.service

echo "🧹 systemd 타이머/서비스 파일 삭제"
sudo rm -f /etc/systemd/system/check-nmcli-connectivity.{service,timer}

echo "🧹 스크립트 파일 삭제"
sudo rm -f /usr/local/bin/check_nmcli_connectivity.sh

echo "🔄 systemd 다시 로드"
sudo systemctl daemon-reload

echo "✅ 모든 설정이 삭제되었습니다."
