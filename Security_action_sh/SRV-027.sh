#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

echo "[SRV-027] 서비스 접근 IP 및 포트 제한 미비 조치" >> $TMP1

# /etc/hosts.deny 파일 설정: 모든 접근을 기본적으로 거부
echo "ALL: ALL" > /etc/hosts.deny
echo "모든 접속을 거부하는 규칙을 /etc/hosts.deny에 설정하였습니다." >> $TMP1

# /etc/hosts.allow 파일 설정: 필요한 서비스 및 IP에 대해서만 접근을 허용
# 예시로 SSH 서비스에 대한 특정 IP 접근만을 허용하는 경우입니다.
# 실제 환경에 맞게 필요한 서비스와 IP 또는 네트워크를 설정해야 합니다.
echo "sshd: 192.168.0.0/24" > /etc/hosts.allow
echo "SSH 서비스에 대한 192.168.0.0/24 네트워크에서의 접근만을 허용하는 규칙을 /etc/hosts.allow에 설정하였습니다." >> $TMP1

BAR

cat "$TMP1"

echo ; echo
