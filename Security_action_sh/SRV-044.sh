#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

echo "[SRV-044] 웹 서비스 파일 업로드 및 다운로드 용량 제한 설정 조치" >> $TMP1

# Apache 설정 파일 경로
APACHE_CONFIG_FILES=("/etc/apache2/apache2.conf" "/etc/apache2/sites-available/*" "/etc/httpd/conf/httpd.conf" "/etc/httpd/conf.d/*")

# 파일 업로드 및 다운로드 용량 제한 (예: 10MB = 10485760 bytes)
LIMIT_REQUEST_BODY="10485760"

for config_file in "${APACHE_CONFIG_FILES[@]}"; do
    if [ -f "$config_file" ] || [ -d "$config_file" ]; then
        # LimitRequestBody 설정 추가
        grep -rl "LimitRequestBody" $config_file | xargs sed -i "s/LimitRequestBody [0-9]*/LimitRequestBody $LIMIT_REQUEST_BODY/"
        if [ $? -ne 0 ]; then
            # LimitRequestBody 설정이 파일 내 존재하지 않으면 추가
            echo "LimitRequestBody $LIMIT_REQUEST_BODY" >> "$config_file"
        fi
        echo "조치: $config_file 파일에 파일 업로드 및 다운로드 용량 제한을 $LIMIT_REQUEST_BODY 바이트로 설정하였습니다." >> $TMP1
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
