#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

echo "[SRV-028] 원격 터미널 접속 타임아웃 설정 조치" >> $TMP1

# SSH 설정 파일 경로
SSH_CONFIG_FILE="/etc/ssh/sshd_config"

# ClientAliveInterval 설정 (예: 300초)
# 이 설정은 서버가 클라이언트에게 무응답 상태에서 생존 확인 메시지를 보내는 간격을 초 단위로 지정합니다.
CLIENT_ALIVE_INTERVAL=300

# ClientAliveCountMax 설정 (예: 3)
# 이 설정은 서버가 클라이언트로부터 응답을 받지 못할 경우 연결을 유지하는 생존 확인 메시지의 최대 횟수를 지정합니다.
CLIENT_ALIVE_COUNT_MAX=3

# ClientAliveInterval 설정 추가/수정
if grep -q "^ClientAliveInterval" "$SSH_CONFIG_FILE"; then
    sed -i "s/^ClientAliveInterval.*/ClientAliveInterval $CLIENT_ALIVE_INTERVAL/" "$SSH_CONFIG_FILE"
else
    echo "ClientAliveInterval $CLIENT_ALIVE_INTERVAL" >> "$SSH_CONFIG_FILE"
fi

# ClientAliveCountMax 설정 추가/수정
if grep -q "^ClientAliveCountMax" "$SSH_CONFIG_FILE"; then
    sed -i "s/^ClientAliveCountMax.*/ClientAliveCountMax $CLIENT_ALIVE_COUNT_MAX/" "$SSH_CONFIG_FILE"
else
    echo "ClientAliveCountMax $CLIENT_ALIVE_COUNT_MAX" >> "$SSH_CONFIG_FILE"
fi

echo "SSH 원격 터미널 타임아웃 설정이 적절하게 구성되었습니다." >> $TMP1

# SSH 서비스 재시작
systemctl restart sshd

echo "SSH 서비스가 재시작되었습니다." >> $TMP1

BAR

cat "$TMP1"

echo ; echo
