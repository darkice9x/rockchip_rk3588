#!/usr/bin/env bash

set -e

ARGV_FILE="$HOME/.config/Code/argv.json"

# 디렉토리 생성
mkdir -p "$(dirname "$ARGV_FILE")"

# 파일이 없으면 빈 JSON 생성
if [ ! -f "$ARGV_FILE" ]; then
    echo "{}" > "$ARGV_FILE"
fi

# jq 존재 여부 확인
if ! command -v jq >/dev/null 2>&1; then
    echo "ERROR: jq가 설치되어 있지 않습니다."
    echo "Ubuntu: sudo apt install jq"
    exit 1
fi

# disable-gpu 설정 추가/갱신
tmpfile=$(mktemp)
jq '. + {"disable-gpu": true}' "$ARGV_FILE" > "$tmpfile"
mv "$tmpfile" "$ARGV_FILE"

echo "완료: disable-gpu=true 가 설정되었습니다."
echo "파일 위치: $ARGV_FILE"
echo "VS Code를 완전히 종료 후 다시 실행하세요."
