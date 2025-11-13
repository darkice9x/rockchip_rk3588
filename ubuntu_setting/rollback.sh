# 1️⃣ 현재 설치된 docker 관련 패키지 확인
pkg=$(apt list --installed 2>/dev/null | grep -E '^docker' | cut -d/ -f1)

# 2️⃣ 각 패키지별 현재 버전 확인 및 이전 버전으로 롤백 명령어 생성
for p in $pkg; do
    echo "==> $p 버전 목록 확인 중..."
    apt list -a $p 2>/dev/null | grep -E '^[^Listing]' | head -n 5

    cur=$(apt list --installed 2>/dev/null | grep "^$p/" | awk '{print $2}' | cut -d, -f1)
    prev=$(apt list -a $p 2>/dev/null | grep -A1 "$cur" | tail -n1 | awk '{print $2}')
    if [ -n "$prev" ]; then
        echo "현재 버전: $cur"
        echo "이전 버전: $prev"
        echo "🔄 되돌리기 명령:"
        echo "sudo apt install $p=$prev"
        echo
    else
        echo "⚠️  이전 버전을 찾을 수 없습니다: $p ($cur)"
        echo
    fi
done
