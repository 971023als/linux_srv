#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

echo "[SRV-043] 웹 서비스 경로 내 불필요한 파일 제거 조치" >> $TMP1

# Apache 설정 파일에서 DocumentRoot 경로 식별
DOCUMENT_ROOTS=($(grep -Ri 'DocumentRoot' /etc/apache2 /etc/httpd 2>/dev/null | grep -v '#' | awk '{print $2}' | sort | uniq))

# 불필요한 파일 유형 정의 (예: 백업 파일, 임시 파일 등)
UNNECESSARY_FILES=("*.bak" "*.tmp" "*.swp")

# DocumentRoot 경로 내 불필요한 파일 제거
for doc_root in "${DOCUMENT_ROOTS[@]}"; do
    for file_type in "${UNNECESSARY_FILES[@]}"; do
        # 해당 유형의 파일 찾기 및 제거
        find "$doc_root" -type f -name "$file_type" -exec rm -f {} +
    done
    echo "조치: $doc_root 내 불필요한 파일 유형($file_type) 제거 완료." >> $TMP1
done

# Apache 서비스 재시작
if systemctl is-active --quiet apache2; then
    systemctl restart apache2
    echo "Apache2 서비스가 재시작되었습니다." >> $TMP1
elif systemctl is-active --quiet httpd; then
    systemctl restart httpd
    echo "HTTPD 서비스가 재시작되었습니다." >> $TMP1
else
    echo "Apache/HTTPD 서비스가 설치되지 않았거나 인식할 수 없습니다." >> $TMP1
fi

BAR

cat "$TMP1"

echo ; echo
