#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

echo "[SRV-023] 원격 터미널 서비스의 암호화 수준 설정 조치" >> $TMP1

# SSH 설정 파일 경로
SSH_CONFIG_FILE="/etc/ssh/sshd_config"

# 사용자로부터 암호화 알고리즘 설정 값을 입력받습니다.
read -p "Enter KexAlgorithms (e.g., curve25519-sha256@libssh.org): " KEX_ALGORITHMS
read -p "Enter Ciphers (e.g., chacha20-poly1305@openssh.com,aes256-gcm@openssh.com): " CIPHERS
read -p "Enter MACs (e.g., hmac-sha2-512-etm@openssh.com): " MACS

# KexAlgorithms 설정
if grep -q "^KexAlgorithms" "$SSH_CONFIG_FILE"; then
    sed -i "/^KexAlgorithms/c\KexAlgorithms $KEX_ALGORITHMS" "$SSH_CONFIG_FILE"
else
    echo "KexAlgorithms $KEX_ALGORITHMS" >> "$SSH_CONFIG_FILE"
fi

# Ciphers 설정
if grep -q "^Ciphers" "$SSH_CONFIG_FILE"; then
    sed -i "/^Ciphers/c\Ciphers $CIPHERS" "$SSH_CONFIG_FILE"
else
    echo "Ciphers $CIPHERS" >> "$SSH_CONFIG_FILE"
fi

# MACs 설정
if grep -q "^MACs" "$SSH_CONFIG_FILE"; then
    sed -i "/^MACs/c\MACs $MACS" "$SSH_CONFIG_FILE"
else
    echo "MACs $MACS" >> "$SSH_CONFIG_FILE"
fi

echo "조치: $SSH_CONFIG_FILE 파일의 암호화 설정을 사용자 입력에 따라 강화하였습니다." >> $TMP1

# SSH 서비스 재시작
systemctl restart sshd

BAR

cat "$TMP1"

echo ; echo
