#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

echo "[SRV-046] 웹 서비스 경로 설정 보안 조치" >> $TMP1

# Apache 설정 파일 경로
APACHE_CONFIG_FILE="/etc/apache2/apache2.conf"

# Apache 설정 파일에서 안전한 경로 설정 적용
if [ -f "$APACHE_CONFIG_FILE" ]; then
    # 디렉터리 리스팅 방지 설정
    sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/Options Indexes/Options -Indexes/' $APACHE_CONFIG_FILE
    echo "Apache 설정 파일($APACHE_CONFIG_FILE)에서 디렉터리 리스팅 방지 설정을 적용했습니다." >> $TMP1
else
    echo "Apache 설정 파일($APACHE_CONFIG_FILE)이 존재하지 않습니다." >> $TMP1
fi

# Nginx 설정 파일 경로
NGINX_CONFIG_FILE="/etc/nginx/nginx.conf"

# Nginx 설정 파일에서 안전한 경로 설정 적용
if [ -f "$NGINX_CONFIG_FILE" ]; then
    # autoindex 옵션 비활성화
    sed -i '/location \/ {/,/}/ s/autoindex on;/autoindex off;/' $NGINX_CONFIG_FILE
    echo "Nginx 설정 파일($NGINX_CONFIG_FILE)에서 autoindex 비활성화 설정을 적용했습니다." >> $TMP1
else
    echo "Nginx 설정 파일($NGINX_CONFIG_FILE)이 존재하지 않습니다." >> $TMP1
fi

# Apache 및 Nginx 서비스 재시작
if systemctl is-active --quiet apache2; then
    systemctl restart apache2
    echo "Apache 서비스가 재시작되었습니다." >> $TMP1
fi

if systemctl is-active --quiet nginx; then
    systemctl restart nginx
    echo "Nginx 서비스가 재시작되었습니다." >> $TMP1
fi

BAR

cat "$TMP1"

echo ; echo
