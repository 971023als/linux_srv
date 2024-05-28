#!/bin/bash

. function.sh

BAR

echo "웹 서비스의 불필요한 스크립트 매핑 제거 조치" >> $result

# Apache 설정 파일 경로
APACHE_CONFIG_FILE="/etc/apache2/apache2.conf"
# Nginx 설정 파일 경로
NGINX_CONFIG_FILE="/etc/nginx/nginx.conf"

# Apache에서 불필요한 스크립트 매핑 제거
if [ -f "$APACHE_CONFIG_FILE" ]; then
    # AddHandler 및 AddType 지시어 제거
    sed -i '/AddHandler/d' "$APACHE_CONFIG_FILE"
    sed -i '/AddType/d' "$APACHE_CONFIG_FILE"
    echo "Apache 설정에서 불필요한 스크립트 매핑을 제거했습니다: $APACHE_CONFIG_FILE" >> $result
fi

# Nginx에서 불필요한 PHP 스크립트 매핑 제거
if [ -f "$NGINX_CONFIG_FILE" ]; then
    # PHP 스크립트 매핑이 포함된 location 블록 제거
    # 주의: 이 조치는 PHP 처리가 필요하지 않은 경우에만 적용해야 합니다.
    sed -i '/location ~ \.php$/{N;N;N;N;d;}' "$NGINX_CONFIG_FILE"
    echo "Nginx 설정에서 불필요한 PHP 스크립트 매핑을 제거했습니다: $NGINX_CONFIG_FILE" >> $result
fi

# 서비스 재시작
if systemctl is-active --quiet apache2; then
    systemctl restart apache2
    echo "Apache 서비스를 재시작했습니다." >> $result
fi
if systemctl is-active --quiet nginx; then
    systemctl restart nginx
    echo "Nginx 서비스를 재시작했습니다." >> $result
fi

cat $result

echo ; echo
