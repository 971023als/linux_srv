#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

echo "[SRV-048] 불필요한 웹 서비스 실행 방지 조치" >> $TMP1

# Apache 홈 디렉터리 식별
APACHE_HOME_DIRS=("/etc/apache2" "/etc/httpd" "/usr/local/apache2" "/usr/local/httpd")

# 불필요한 파일 및 디렉터리 목록
UNNECESSARY_DIRS=("manual" "cgi-bin" "icons")

# Apache 홈 디렉터리에서 불필요한 파일 및 디렉터리 제거
for apache_dir in "${APACHE_HOME_DIRS[@]}"; do
    if [ -d "$apache_dir" ]; then
        for dir in "${UNNECESSARY_DIRS[@]}"; do
            if [ -d "$apache_dir/$dir" ]; then
                rm -rf "$apache_dir/$dir"
                echo "제거: $apache_dir/$dir" >> $TMP1
            fi
        done
    fi
done

echo "모든 불필요한 파일 및 디렉터리가 Apache 홈 디렉터리에서 제거되었습니다." >> $TMP1

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
