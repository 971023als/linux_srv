#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

echo "[SRV-055] 웹 서비스 설정 파일 보호 조치" >> $TMP1

# Apache 설정 파일 경로
APACHE_CONFIG="/etc/apache2/apache2.conf"
# Nginx 설정 파일 경로
NGINX_CONFIG="/etc/nginx/nginx.conf"

# Apache 설정 파일의 접근 권한 변경
if [ -f "$APACHE_CONFIG" ]; then
  chmod 600 "$APACHE_CONFIG"
  echo "Apache 설정 파일($APACHE_CONFIG)의 접근 권한을 600으로 변경했습니다." >> $TMP1
else
  echo "Apache 설정 파일($APACHE_CONFIG)이 존재하지 않습니다." >> $TMP1
fi

# Nginx 설정 파일의 접근 권한 변경
if [ -f "$NGINX_CONFIG" ]; then
  chmod 600 "$NGINX_CONFIG"
  echo "Nginx 설정 파일($NGINX_CONFIG)의 접근 권한을 600으로 변경했습니다." >> $TMP1
else
  echo "Nginx 설정 파일($NGINX_CONFIG)이 존재하지 않습니다." >> $TMP1
fi

BAR

cat "$TMP1"

echo ; echo
