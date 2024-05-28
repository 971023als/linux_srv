#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

CODE [SRV-148] 웹 서비스 정보 노출

cat << EOF >> $TMP1
[양호]: 웹 서버에서 버전 정보 및 운영체제 정보 노출이 제한된 경우
[취약]: 웹 서버에서 버전 정보 및 운영체제 정보가 노출되는 경우
EOF

BAR

# Apache 설정 파일 경로 지정 (환경에 따라 수정 필요)
apache_conf="/etc/apache2/apache2.conf"

# 설정 파일이 존재하는지 확인
if [ -f "$apache_conf" ]; then
    # ServerTokens Prod 설정 추가
    if ! grep -q "ServerTokens Prod" "$apache_conf"; then
        echo "ServerTokens Prod" >> "$apache_conf"
        echo "ServerTokens Prod 설정이 추가되었습니다." >> $TMP1
    fi
    
    # ServerSignature Off 설정 추가
    if ! grep -q "ServerSignature Off" "$apache_conf"; then
        echo "ServerSignature Off" >> "$apache_conf"
        echo "ServerSignature Off 설정이 추가되었습니다." >> $TMP1
    fi
    
    OK "Apache 설정이 업데이트되었습니다." >> $TMP1
else
    WARN "Apache 설정 파일($apache_conf)을 찾을 수 없습니다." >> $TMP1
fi

cat $TMP1

echo ; echo
