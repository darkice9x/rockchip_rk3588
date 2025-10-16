#!/bin/bash
# rknn_lite.py 수정 스크립트
# pkg_resources → importlib.metadata
# 사용법: ./patch_rknn_lite.sh [디렉토리경로]
# 예: ./patch_rknn_lite.sh ~/projects/rknn

# === 인자 처리 ===
BASE_DIR="${1:-.}"

if [ ! -d "$BASE_DIR" ]; then
    echo "❌ 경로가 존재하지 않습니다: $BASE_DIR"
    exit 1
fi

echo "🔍 '$BASE_DIR' 하위에서 rknn_lite.py 탐색 중..."
count=0

# === 파일 탐색 및 수정 ===
while IFS= read -r file; do
    if grep -q "pkg_resources" "$file"; then
        echo "✅ 수정 중: $file"
        cp "$file" "$file.bak"  # 백업 생성

        # import pkg_resources → from importlib.metadata import version
        sed -i 's/import pkg_resources/from importlib.metadata import version/' "$file"

        # pkg_resources.get_distribution("rknn-toolkit-lite2").version → version("rknn-toolkit-lite2")
        sed -i 's/pkg_resources\.get_distribution("rknn-toolkit-lite2")\.version/version("rknn-toolkit-lite2")/' "$file"

        count=$((count + 1))
    fi
done < <(find "$BASE_DIR" -type f -name "rknn_lite.py")

# === 결과 출력 ===
if [ "$count" -eq 0 ]; then
    echo "⚠️ 수정할 파일이 없습니다."
else
    echo "✅ 총 $count 개의 파일이 수정되었습니다."
fi
