#!/bin/bash

set -e

IFACE="wlP2p33s0"
SSID="Homeiptime5G"
PASSWORD="@sys3275423"

echo ">> Checking NetworkManager..."
systemctl is-active --quiet NetworkManager || {
    echo "ERROR: NetworkManager is not running"
    exit 1
}

echo ">> Checking Wi-Fi device state..."
nmcli device status | grep -q "^$IFACE.*wifi" || {
    echo "ERROR: Interface $IFACE not found"
    exit 1
}

echo ">> Enabling Wi-Fi radio..."
nmcli radio wifi on

echo ">> Rescanning Wi-Fi networks..."
nmcli device wifi rescan ifname "$IFACE"
sleep 2

echo ">> Checking existing connection profile..."
CON_NAME=$(nmcli -t -f NAME,DEVICE con show | grep ":$IFACE$" | cut -d: -f1 || true)

if [ -z "$CON_NAME" ]; then
    echo ">> No active profile on $IFACE, checking saved profile for $SSID..."
    CON_NAME=$(nmcli -t -f NAME con show | grep "^$SSID$" || true)
fi

if [ -z "$CON_NAME" ]; then
    echo ">> No existing profile, creating new connection for $SSID"
    nmcli device wifi connect "$SSID" password "$PASSWORD" ifname "$IFACE"
else
    echo ">> Using existing connection profile: $CON_NAME"
    nmcli connection up "$CON_NAME" ifname "$IFACE"
fi

echo ">> Waiting for connection..."
sleep 3

STATE=$(nmcli -t -f DEVICE,STATE dev status | grep "^$IFACE:" | cut -d: -f2)

if [ "$STATE" = "connected" ]; then
    echo ">> SUCCESS: $IFACE is connected to $SSID"
    ip addr show "$IFACE"
    ip route
else
    echo "ERROR: Connection failed, current state: $STATE"
    nmcli device status
    exit 1
fi
