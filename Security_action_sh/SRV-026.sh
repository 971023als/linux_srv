#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

echo "[SRV-026] root 계정 원격 접속 제한 미비 조치" >> $TMP1

# SSH 설정 파일 경로
SSH_CONFIG_FILE="/etc/ssh/sshd_config"

# PermitRootLogin 설정을 확인하고, 필요한 경우 수정합니다.
if grep -q "^PermitRootLogin" $SSH_CONFIG_FILE; then
    # PermitRootLogin이 이미 설정되어 있는 경우, 값을 'no'로 변경합니다.
    sed -i '/^PermitRootLogin/c\PermitRootLogin no' $SSH_CONFIG_FILE
    echo "조치: PermitRootLogin 설정이 'no'로 변경되었습니다." >> $TMP1
else
    # PermitRootLogin 설정이 없는 경우, 파일 끝에 'PermitRootLogin no'를 추가합니다.
    echo "PermitRootLogin no" >> $SSH_CONFIG_FILE
    echo "조치: PermitRootLogin 설정이 추가되고, 'no'로 설정되었습니다." >> $TMP1
fi

# SSH 서비스 재시작
systemctl restart sshd

echo "SSH 서비스가 재시작되었습니다." >> $TMP1

BAR

cat $TMP1

echo ; echo
