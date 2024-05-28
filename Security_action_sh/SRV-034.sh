#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

echo "[SRV-034] 불필요한 서비스 비활성화 조치" >> $TMP1

# 불필요한 r 계열 서비스 목록
r_command=("rsh" "rlogin" "rexec" "shell" "login" "exec")

# /etc/xinetd.d 디렉터리 내의 서비스 비활성화
if [ -d /etc/xinetd.d ]; then
    for service in "${r_command[@]}"; do
        if [ -f /etc/xinetd.d/$service ]; then
            sed -i 's/disable[ \t]*=[ \t]*no/disable = yes/' /etc/xinetd.d/$service
            echo "조치: $service 서비스가 /etc/xinetd.d 내에서 비활성화되었습니다." >> $TMP1
        fi
    done
fi

# /etc/inetd.conf 파일 내의 서비스 비활성화
if [ -f /etc/inetd.conf ]; then
    for service in "${r_command[@]}"; do
        if grep -q "$service" /etc/inetd.conf; then
            sed -i "/$service/s/^/#/" /etc/inetd.conf
            echo "조치: $service 서비스가 /etc/inetd.conf 파일 내에서 비활성화되었습니다." >> $TMP1
        fi
    done
fi

echo "모든 불필요한 서비스에 대한 비활성화 조치가 완료되었습니다." >> $TMP1

BAR

cat "$TMP1"

echo ; echo
