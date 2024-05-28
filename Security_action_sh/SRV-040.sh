#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

echo "[SRV-040] 웹 서비스 디렉터리 리스팅 방지 설정 조치" >> $TMP1

# Apache 설정 파일 검색 및 수정
webconf_files=("/etc/apache2/apache2.conf" "/etc/apache2/conf-available/*" "/etc/apache2/sites-available/*" "/etc/httpd/conf/httpd.conf" "/etc/httpd/conf.d/*")

for file_path in "${webconf_files[@]}"; do
    if [ -f $file_path ] || [ -d $file_path ]; then
        # 디렉터리 리스팅 방지 설정 적용
        grep -rl "Options Indexes" $file_path | xargs sed -i 's/Options Indexes/Options -Indexes/g'
        echo "조치: $file_path 내 디렉터리 리스팅이 방지되도록 설정되었습니다." >> $TMP1
    fi
done

# Apache 서비스 재시작
if systemctl is-active --quiet apache2; then
    systemctl restart apache2
    echo "Apache 서비스가 재시작되었습니다." >> $TMP1
elif systemctl is-active --quiet httpd; then
    systemctl restart httpd
    echo "HTTPD 서비스가 재시작되었습니다." >> $TMP1
else
    echo "Apache/HTTPD 서비스가 설치되지 않았거나 인식할 수 없습니다." >> $TMP1
fi

BAR

cat "$TMP1"

echo ; echo
