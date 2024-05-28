#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

echo "[SRV-047] 웹 서비스 경로 내 불필요한 심볼릭 링크 파일 제거 및 설정 조치" >> $TMP1

# Apache 설정 파일 경로
APACHE_CONFIG_FILES=("/etc/apache2/apache2.conf" "/etc/apache2/sites-available/*" "/etc/httpd/conf/httpd.conf" "/etc/httpd/conf.d/*")

# 심볼릭 링크 사용 제한 설정 적용
for config_file in "${APACHE_CONFIG_FILES[@]}"; do
    if [ -f "$config_file" ] || [ -d "$config_file" ]; then
        # FollowSymLinks 옵션을 SymLinksIfOwnerMatch로 변경하여 보안 강화
        sed -i 's/Options .*FollowSymLinks/Options -Indexes +SymLinksIfOwnerMatch/g' "$config_file"
        echo "조치: $config_file 파일에서 심볼릭 링크 사용 제한 설정을 적용했습니다." >> $TMP1
    fi
done

# DocumentRoot 경로 식별 및 불필요한 심볼릭 링크 제거
DOCUMENT_ROOT=$(grep -Ri 'DocumentRoot' /etc/apache2 /etc/httpd 2>/dev/null | grep -v '#' | awk '{print $2}' | sort | uniq)
for doc_root in $DOCUMENT_ROOT; do
    if [ -d "$doc_root" ]; then
        # 불필요한 심볼릭 링크 찾기 및 제거
        find "$doc_root" -type l -exec rm -f {} \;
        echo "조치: $doc_root 경로 내 불필요한 심볼릭 링크 파일을 제거했습니다." >> $TMP1
    fi
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
