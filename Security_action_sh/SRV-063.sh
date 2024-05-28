#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

echo "[SRV-063] DNS Recursive Query 제한 설정 조치" >> $TMP1

# DNS 설정 파일 경로
DNS_CONFIG_FILE="/etc/bind/named.conf.options" # BIND 예시, 실제 파일 경로는 다를 수 있음

# 재귀 쿼리를 localhost와 localnets에만 허용하는 설정 추가
if ! grep -E "allow-recursion" "$DNS_CONFIG_FILE"; then
    # allow-recursion 설정이 없는 경우, 설정을 추가합니다.
    echo "options {" >> "$DNS_CONFIG_FILE"
    echo "    allow-recursion { localhost; localnets; };" >> "$DNS_CONFIG_FILE"
    echo "};" >> "$DNS_CONFIG_FILE"
    echo "DNS 서버의 재귀적 쿼리를 localhost와 localnets에만 제한하는 설정을 추가했습니다." >> $TMP1
else
    # allow-recursion 설정이 이미 있는 경우, 경고 메시지를 출력합니다.
    echo "DNS 서버의 재귀적 쿼리 제한 설정이 이미 존재합니다. 수동으로 검토가 필요할 수 있습니다." >> $TMP1
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
