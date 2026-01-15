#!/bin/bash

SETTINGS="$HOME/.config/Code/User/settings.json"

mkdir -p "$(dirname "$SETTINGS")"

# 파일 없으면 생성
if [ ! -f "$SETTINGS" ] || [ ! -s "$SETTINGS" ]; then
    cat > "$SETTINGS" <<EOT
{
  "terminal.integrated.cwd": "\${fileDirname}"
}
EOT
    echo "[OK] settings.json created with terminal.integrated.cwd"
    exit 0
fi

# 이미 키가 있으면 교체
if grep -q '"terminal.integrated.cwd"' "$SETTINGS"; then
    sed -i 's|"terminal.integrated.cwd"[[:space:]]*:[[:space:]]*".*"|"terminal.integrated.cwd": "${fileDirname}"|g' "$SETTINGS"
    echo "[OK] terminal.integrated.cwd updated"
    exit 0
fi

# 키가 없으면: 마지막 설정 줄 다음 줄에 추가 ( } 바로 위가 아니라, 마지막 항목 뒤에 )
awk '
BEGIN { inserted = 0 }
{
    if ($0 ~ /^[[:space:]]*}/ && inserted == 0) {
        # 직전 줄이 , 로 끝나지 않으면 , 추가
        if (prev !~ /,[[:space:]]*$/) {
            sub(/[[:space:]]*$/, ",", prev)
        }
        print prev
        print "    \"terminal.integrated.cwd\": \"${fileDirname}\""
        print $0
        inserted = 1
    } else {
        if (NR > 1) print prev
        prev = $0
    }
}
END {
    if (inserted == 0 && prev != "") print prev
}
' "$SETTINGS" > "${SETTINGS}.tmp" && mv "${SETTINGS}.tmp" "$SETTINGS"

echo "[OK] terminal.integrated.cwd added after last entry"

