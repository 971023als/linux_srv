#!/bin/bash

. function.sh

# 결과 파일 초기화
TMP1=$(basename "$0").log
> $TMP1

BAR

echo "[SRV-011] 시스템 관리자 계정의 FTP 사용 제한 조치" >> $TMP1

# FTP 사용자 제한 설정 파일 경로
FTP_USERS_FILE="/etc/vsftpd/ftpusers"

# 'root' 계정의 FTP 접근 제한 조치
if [ -f "$FTP_USERS_FILE" ]; then
    if grep -q "^root" "$FTP_USERS_FILE"; then
        echo "OK: FTP 서비스에서 root 계정의 접근이 이미 제한됩니다." >> $TMP1
    else
        echo "INFO: FTP 서비스에서 root 계정의 접근을 제한합니다." >> $TMP1
        echo "root" >> "$FTP_USERS_FILE"
        echo "APPLIED: FTP 서비스에 대한 root 계정 접근 제한을 적용하였습니다." >> $TMP1
    fi
else
    echo "INFO: FTP 사용자 제한 설정 파일($FTP_USERS_FILE)이 존재하지 않습니다. 파일을 생성하고 root 계정을 제한합니다." >> $TMP1
    echo "root" > "$FTP_USERS_FILE"
    echo "CREATED & APPLIED: FTP 사용자 제한 설정 파일을 생성하고, root 계정 접근 제한을 적용하였습니다." >> $TMP1
fi

cat $TMP1
echo ; echo
