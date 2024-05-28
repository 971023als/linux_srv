#!/bin/bash

# 초기 설정
TMP1="$(SCRIPTNAME).log"
> "$TMP1"

echo "네트워크 서비스의 접근 제한 설정 점검" >> "$TMP1"
echo "=====================================" >> "$TMP1"

# /etc/hosts.deny 파일 점검 및 설정
if [ ! -f /etc/hosts.deny ]; then
    echo "WARN: /etc/hosts.deny 파일이 존재하지 않습니다. 파일을 생성합니다." >> "$TMP1"
    echo "ALL: ALL" > /etc/hosts.deny
    echo "OK: /etc/hosts.deny 파일에 'ALL: ALL' 설정을 추가하였습니다." >> "$TMP1"
else
    echo "OK: /etc/hosts.deny 파일이 존재합니다." >> "$TMP1"
    if ! grep -q "ALL: ALL" /etc/hosts.deny; then
        echo "ALL: ALL" >> /etc/hosts.deny
        echo "OK: /etc/hosts.deny 파일에 'ALL: ALL' 설정을 추가하였습니다." >> "$TMP1"
    else
        echo "OK: /etc/hosts.deny 파일에 'ALL: ALL' 설정이 이미 존재합니다." >> "$TMP1"
    fi
fi

# /etc/hosts.allow 파일 점검 및 예외 설정 추가
if [ -f /etc/hosts.allow ]; then
    echo "OK: /etc/hosts.allow 파일이 존재합니다." >> "$TMP1"
    # 필요한 예외 규칙 추가 예시
    # echo "sshd: 192.168.0.0/24" >> /etc/hosts.allow
else
    echo "INFO: /etc/hosts.allow 파일이 존재하지 않습니다. 필요한 경우 파일을 생성하고 규칙을 추가하세요." >> "$TMP1"
fi

# 결과 파일 출력
cat "$TMP1"
echo
