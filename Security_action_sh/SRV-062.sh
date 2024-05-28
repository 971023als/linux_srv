#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

echo "[SRV-062] DNS 서비스 정보 보호 조치" >> $TMP1

# DNS 설정 파일 경로
DNS_CONFIG_FILE="/etc/bind/named.conf"  # BIND 사용 예시, 실제 환경에 따라 달라질 수 있음

# 버전 정보 숨김 설정 추가
if ! grep -qE "version \"none\"" "$DNS_CONFIG_FILE"; then
    echo 'options { version "none"; };' >> "$DNS_CONFIG_FILE"
    echo "DNS 서비스의 버전 정보 숨김 옵션을 추가했습니다." >> $TMP1
else
    echo "DNS 서비스의 버전 정보 숨김 옵션은 이미 설정되어 있습니다." >> $TMP1
fi

# 불필요한 Zone Transfer 제한 설정 확인 및 추가
if ! grep -qE "allow-transfer" "$DNS_CONFIG_FILE"; then
    echo 'options { allow-transfer { none; }; };' >> "$DNS_CONFIG_FILE"
    echo "DNS 서비스에서 불필요한 Zone Transfer 제한 옵션을 추가했습니다." >> $TMP1
else
    echo "DNS 서비스에서 불필요한 Zone Transfer 제한 옵션은 이미 설정되어 있습니다." >> $TMP1
fi

# DNS 서비스 재시작 (BIND 사용 예시)
if systemctl is-active --quiet bind9; then
    systemctl restart bind9
    echo "BIND DNS 서비스를 재시작했습니다." >> $TMP1
elif systemctl is-active --quiet named; then
    systemctl restart named
    echo "BIND DNS 서비스(named)를 재시작했습니다." >> $TMP1
else
    echo "DNS 서비스(BIND)가 실행 중이지 않거나, 서비스 명이 다릅니다." >> $TMP1
fi

BAR

cat "$TMP1"

echo ; echo
