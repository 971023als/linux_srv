#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

echo "[SRV-059] 웹 서비스 서버 명령 실행 기능 제한 조치" >> $TMP1

# Apache 설정 파일 경로
APACHE_CONFIG_FILE="/etc/apache2/apache2.conf"
# Nginx 설정 파일 경로
NGINX_CONFIG_FILE="/etc/nginx/nginx.conf"

# Apache에서 서버 명령 실행 제한 설정
if [ -f "$APACHE_CONFIG_FILE" ]; then
    # ScriptAlias 지시어 제거
    sed -i '/ScriptAlias/d' "$APACHE_CONFIG_FILE"
    echo "Apache 설정에서 ScriptAlias를 제거하여 서버 명령 실행을 제한했습니다: $APACHE_CONFIG_FILE" >> $TMP1
fi

# Nginx에서 FastCGI 스크립트 실행 제한 설정
if [ -f "$NGINX_CONFIG_FILE" ]; then
    # fastcgi_pass 지시어가 포함된 블록을 주석 처리
    # 주의: 이 조치는 FastCGI를 사용하는 유효한 애플리케이션이 없는 경우에만 적용해야 합니다.
    sed -i '/fastcgi_pass/s/^/#/' "$NGINX_CONFIG_FILE"
    echo "Nginx 설정에서 fastcgi_pass를 주석 처리하여 FastCGI를 통한 서버 명령 실행을 제한했습니다: $NGINX_CONFIG_FILE" >> $TMP1
fi

# 서비스 재시작
if systemctl is-active --quiet apache2; then
    systemctl restart apache2
    echo "Apache 서비스를 재시작했습니다." >> $TMP1
fi
if systemctl is-active --quiet nginx; then
    systemctl restart nginx
    echo "Nginx 서비스를 재시작했습니다." >> $TMP1
fi

BAR

cat "$TMP1"

echo ; echo
