#!/bin/bash

set -e

echo "======================================"
echo " Wi-Fi Reset → Select → Static IP Set "
echo "======================================"

# 1. 현재 활성 Wi-Fi 디바이스 및 연결명 정확히 탐지 (인터페이스 이름 무관)
ACTIVE_WIFI_LINE=$(nmcli -t -f DEVICE,TYPE,STATE,CONNECTION dev status | grep ":wifi:connected:")

ACTIVE_WIFI_DEVICE=$(echo "$ACTIVE_WIFI_LINE" | cut -d: -f1)
ACTIVE_WIFI_CONN=$(echo "$ACTIVE_WIFI_LINE" | cut -d: -f4)

if [ -n "$ACTIVE_WIFI_DEVICE" ] && [ -n "$ACTIVE_WIFI_CONN" ]; then
    echo
    echo "[INFO] 기존 Wi-Fi 연결 감지됨"
    echo "       Device : $ACTIVE_WIFI_DEVICE"
    echo "       Conn   : $ACTIVE_WIFI_CONN"
    echo "[INFO] 연결 해제 및 프로파일 삭제 중..."

    nmcli dev disconnect "$ACTIVE_WIFI_DEVICE"
    nmcli con delete "$ACTIVE_WIFI_CONN"

    echo "[OK] 기존 Wi-Fi 연결 완전 제거 완료"
else
    echo
    echo "[INFO] 활성 Wi-Fi 연결 없음"
fi

# 2. Wi-Fi 스캔
nmcli dev wifi rescan >/dev/null 2>&1
sleep 2

mapfile -t WIFI_LIST < <(nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY dev wifi list)

if [ ${#WIFI_LIST[@]} -eq 0 ]; then
    echo "[ERROR] Wi-Fi 목록을 가져오지 못했습니다."
    exit 1
fi

echo
echo "사용 가능한 Wi-Fi 목록:"
echo "--------------------------------------------"

i=1
for line in "${WIFI_LIST[@]}"; do
    IFS=':' read -r INUSE SSID SIGNAL SECURITY <<< "$line"

    # SSID 없는 항목은 표시만 하고 선택 불가 처리
    if [ -z "$SSID" ]; then
        DISPLAY_SSID="(Hidden Network)"
    else
        DISPLAY_SSID="$SSID"
    fi

    printf "%2d) %-20s  %3s  %s\n" "$i" "$DISPLAY_SSID" "$SIGNAL" "$SECURITY"
    ((i++))
done

echo "--------------------------------------------"
read -p "연결할 Wi-Fi 번호 선택: " SEL

if ! [[ "$SEL" =~ ^[0-9]+$ ]] || [ "$SEL" -lt 1 ] || [ "$SEL" -gt "${#WIFI_LIST[@]}" ]; then
    echo "[ERROR] 잘못된 선택입니다."
    exit 1
fi

SELECTED_LINE="${WIFI_LIST[$((SEL-1))]}"
IFS=':' read -r _ SSID _ _ <<< "$SELECTED_LINE"

if [ -z "$SSID" ]; then
    echo "[ERROR] 선택한 네트워크는 SSID가 숨김 처리되어 있어 자동 연결할 수 없습니다."
    exit 1
fi

echo
echo "선택된 SSID: $SSID"


# 3. 비밀번호 입력
read -s -p "Wi-Fi 비밀번호: " WIFI_PASS
echo

# 4. 고정 IP 정보 입력
echo
echo "고정 IP 정보 입력"
#read -p "IP 주소 (예: 192.168.0.20): " IP_ADDR
IP_ADDR="192.168.0.3"
#read -p "서브넷 (CIDR, 예: 24): " CIDR
CIDR="24"
#read -p "게이트웨이 (예: 192.168.0.1): " GATEWAY
GATEWAY="192.168.0.1"
#read -p "DNS (공백구분, 예: 8.8.8.8 1.1.1.1): " DNS
DNS="1.1.1.1 8.8.8.8"

IP_FULL="${IP_ADDR}/${CIDR}"

echo
echo "=============================="
echo " 설정 요약"
echo " SSID     : $SSID"
echo " IP       : $IP_FULL"
echo " Gateway  : $GATEWAY"
echo " DNS      : $DNS"
echo "=============================="

read -p "이대로 진행할까요? (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "취소되었습니다."
    exit 0
fi

# 5. Wi-Fi 연결
echo
echo "[1/4] Wi-Fi 연결 시도..."
nmcli dev wifi connect "$SSID" password "$WIFI_PASS"

# 6. 연결 이름 추출
# 연결 반영 대기 (타이밍 문제 방지)
sleep 2

WIFI_DEVICE=$(nmcli -t -f DEVICE,TYPE dev status | grep ":wifi" | cut -d: -f1)

if [ -z "$WIFI_DEVICE" ]; then
    echo "[ERROR] Wi-Fi 디바이스를 찾지 못했습니다."
    exit 1
fi

# 해당 디바이스에 연결된 connection 이름 추출 (가장 안정적인 방식)
CONN_NAME=$(nmcli -t -f DEVICE,CONNECTION dev status | grep "^${WIFI_DEVICE}:" | cut -d: -f2)

if [ -z "$CONN_NAME" ] || [ "$CONN_NAME" = "--" ]; then
    echo "[ERROR] 활성 Wi-Fi 연결을 찾지 못했습니다."
    echo "디버그 정보:"
    nmcli dev status
    exit 1
fi

echo "[OK] 활성 Wi-Fi 연결 감지됨"
echo "     Device : $WIFI_DEVICE"
echo "     Conn   : $CONN_NAME"


echo "[OK] 연결 이름: $CONN_NAME"

# 7. 고정 IP 설정 적용
echo "[2/4] 고정 IP 설정 적용 중..."

nmcli con mod "$CONN_NAME" \
    ipv4.method manual \
    ipv4.addresses "$IP_FULL" \
    ipv4.gateway "$GATEWAY" \
    ipv4.dns "$DNS"

if [ $? -ne 0 ]; then
    echo "[ERROR] 고정 IP 설정 적용 실패"
    nmcli con show "$CONN_NAME"
    exit 1
fi

# 8. 재적용
echo "[3/4] 네트워크 재시작..."
nmcli con down "$CONN_NAME"
nmcli con up "$CONN_NAME"

echo "[4/4] 완료 확인..."

ip a | grep -A2 wlan

echo
echo "======================================"
echo " 완료: $SSID → 고정 IP 설정 성공"
echo "======================================"
