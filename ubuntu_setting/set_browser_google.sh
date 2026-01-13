#!/usr/bin/env bash

set -e

echo "=== Chromium Google Search Engine Auto Config ==="

# 1) Chromium 완전 종료
echo "[*] Stopping Chromium..."
pkill -f chromium || true
sleep 1

BASE="$HOME/.config/chromium/Default"

if [ ! -d "$BASE" ]; then
    echo "[ERROR] Chromium config directory not found: $BASE"
    exit 1
fi

# 2) 모든 프로필 순회
PREF="$BASE/Preferences"
if [ ! -f "$PREF" ]; then
	continue
fi

echo "[*] Processing: $PREF"

# 백업
cp "$PREF" "$PREF.bak.$(date +%Y%m%d_%H%M%S)"

# 3) jq 필요 여부 확인
if ! command -v jq >/dev/null 2>&1; then
	echo "[ERROR] jq not installed. Install with: sudo apt install -y jq"
	exit 1
fi

# 4) Google 검색엔진 강제 설정
TMP=$(mktemp)

jq '
.default_search_provider = {
	"enabled": true,
	"name": "Google",
	"keyword": "google.com",
	"search_url": "https://www.google.com/search?q={searchTerms}"
}
|
.default_search_provider_data = {
	"template_url_data": {
		"id": "1",
		"short_name": "Google",
		"keyword": "google.com",
		"favicon_url": "https://www.google.com/favicon.ico",
		"url": "https://www.google.com/search?q={searchTerms}",
		"suggestions_url": "https://suggestqueries.google.com/complete/search?output=firefox&q={searchTerms}",
		"safe_for_autoreplace": true,
		"is_active": true
	}
}
|
.search.default_search_provider_enabled = true
' "$PREF" > "$TMP"

mv "$TMP" "$PREF"

echo "    -> Google set successfully."

echo "=== DONE. Launch Chromium and check chrome://settings/search ==="
