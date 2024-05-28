#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

echo "[SRV-045] 웹 서비스 프로세스 권한 제한 설정 조치" >> $TMP1

# Apache 설정 파일 경로
APACHE_CONFIG_FILE="/etc/apache2/apache2.conf"

# root 권한이 아닌 사용자와 그룹으로 Apache를 실행하도록 설정
# 일반적으로 'www-data' 또는 'apache' 사용자 및 그룹이 사용됩니다.
WEB_USER="www-data"
WEB_GROUP="www-data"

# Apache 설정 파일에서 User 및 Group 지시어를 찾아 수정하거나 추가
if grep -q "^User" "$APACHE_CONFIG_FILE"; then
    sed -i "s/^User .*/User $WEB_USER/" "$APACHE_CONFIG_FILE"
else
    echo "User $WEB_USER" >> "$APACHE_CONFIG_FILE"
fi

if grep -q "^Group" "$APACHE_CONFIG_FILE"; then
    sed -i "s/^Group .*/Group $WEB_GROUP/" "$APACHE_CONFIG_FILE"
else
    echo "Group $WEB_GROUP" >> "$APACHE_CONFIG_FILE"
fi

echo "조치: Apache 데몬이 $WEB_USER 사용자 및 $WEB_GROUP 그룹으로 구동되도록 설정되었습니다." >> $TMP1

# Apache 서비스 재시작
systemctl restart apache2

echo "Apache 서비스가 재시작되었습니다." >> $TMP1

BAR

cat "$TMP1"

echo ; echo
