#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

echo "[SRV-037] 취약한 FTP 서비스 실행 조치" >> $TMP1

# FTP 서비스 비활성화
# 시스템에서 사용 중인 FTP 데몬을 확인하고 비활성화합니다.
# vsftpd와 proftpd 예시로 비활성화
FTP_SERVICES=("vsftpd" "proftpd")

for service in "${FTP_SERVICES[@]}"; do
    if systemctl is-enabled --quiet $service; then
        systemctl stop $service
        systemctl disable $service
        echo "조치: $service 서비스가 비활성화되었습니다." >> $TMP1
    else
        echo "조치: $service 서비스가 이미 비활성화되어 있습니다." >> $TMP1
    fi
done

# /etc/xinetd.d 내 FTP 관련 서비스 파일 비활성화
if [ -d /etc/xinetd.d ]; then
    for service_file in /etc/xinetd.d/*ftp*; do
        if [ -f "$service_file" ]; then
            sed -i 's/disable[ \t]*=[ \t]*no/disable = yes/' "$service_file"
            echo "조치: $service_file 내 서비스가 비활성화되었습니다." >> $TMP1
        fi
    done
fi

echo "모든 취약한 FTP 서비스에 대한 비활성화 조치가 완료되었습니다." >> $TMP1

BAR

cat "$TMP1"

echo ; echo
