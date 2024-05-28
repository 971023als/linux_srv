#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

echo "[SRV-057] 웹 서비스 경로 내 파일의 접근 통제 조치" >> $TMP1

# 웹 서비스 경로 설정
WEB_SERVICE_PATH="/var/www/html" # 실제 경로에 맞게 조정하세요.

# 웹 서비스 경로 내 파일 접근 권한 설정
# 모든 파일에 대해 755 권한 설정
find "$WEB_SERVICE_PATH" -type f -exec chmod 755 {} \;

# 모든 디렉토리에 대해 755 권한 설정
find "$WEB_SERVICE_PATH" -type d -exec chmod 755 {} \;

echo "웹 서비스 경로($WEB_SERVICE_PATH) 내의 모든 파일 및 디렉토리의 권한을 755으로 설정했습니다." >> $TMP1

BAR

cat "$TMP1"

echo ; echo
