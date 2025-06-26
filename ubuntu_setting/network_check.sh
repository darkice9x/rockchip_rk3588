#!/bin/bash

# 1. 스크립트 저장
cat << 'EOF' | sudo tee /usr/local/bin/check_nmcli_connectivity.sh > /dev/null
#!/bin/bash
STATE=$(nmcli networking connectivity)
if [ "$STATE" != "full" ]; then
    echo "[!] 인터넷 연결 상태 아님 ($STATE). NetworkManager 재시작 중..."
    nmcli radio wifi on
    systemctl restart NetworkManager
else
    echo "[✓] 인터넷 연결 정상 ($STATE)"
fi
EOF

# 2. 실행 권한 부여
sudo chmod +x /usr/local/bin/check_nmcli_connectivity.sh

# 3. systemd 서비스 생성
cat << 'EOF' | sudo tee /etc/systemd/system/check-nmcli-connectivity.service > /dev/null
[Unit]
Description=nmcli로 인터넷 연결 상태 확인 및 NetworkManager 재시작

[Service]
Type=oneshot
ExecStart=/usr/local/bin/check_nmcli_connectivity.sh
EOF

# 4. systemd 타이머 생성
cat << 'EOF' | sudo tee /etc/systemd/system/check-nmcli-connectivity.timer > /dev/null
[Unit]
Description=5분마다 nmcli 연결 상태 확인

[Timer]
OnBootSec=30sec
OnUnitActiveSec=5min
Unit=check-nmcli-connectivity.service

[Install]
WantedBy=timers.target
EOF

# 5. systemd 적용 및 타이머 실행
sudo systemctl daemon-reload
sudo systemctl enable --now check-nmcli-connectivity.timer

echo "✅ nmcli 기반 네트워크 자동 점검 타이머가 설정되었습니다."
