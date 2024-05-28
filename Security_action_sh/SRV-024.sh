#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

echo "[SRV-024] 취약한 Telnet 인증 방식 사용 조치" >> $TMP1

# Telnet 서비스 비활성화
if systemctl is-active --quiet telnet.socket; then
    systemctl stop telnet.socket
    systemctl disable telnet.socket
    echo "Telnet 서비스가 비활성화되었습니다." >> $TMP1
else
    echo "Telnet 서비스가 이미 비활성화되어 있습니다." >> $TMP1
fi

# 안전한 원격 접속을 위해 SSH 서비스를 권장합니다.
# SSH 서비스 상태 확인 및 활성화
if ! systemctl is-active --quiet sshd; then
    systemctl start sshd
    systemctl enable sshd
    echo "SSH 서비스가 활성화되었습니다. 안전한 원격 접속을 위해 SSH 사용을 권장합니다." >> $TMP1
else
    echo "SSH 서비스가 이미 활성화되어 있습니다." >> $TMP1
fi

BAR

cat "$TMP1"

echo ; echo
