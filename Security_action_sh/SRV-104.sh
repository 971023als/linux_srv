#!/bin/bash

# 결과 파일 정의
TMP1="$(SCRIPTNAME).log"
> $TMP1

echo "보안 채널 데이터 디지털 암호화 또는 서명 기능 비활성화 여부 점검" >> $TMP1
echo "=============================================================" >> $TMP1

# sshd_config 파일 위치 정의
SSHD_CONFIG="/etc/ssh/sshd_config"

# sshd_config 파일이 존재하는지 확인합니다.
if [ -f "$SSHD_CONFIG" ]; then
    # Ciphers 및 MACs 설정을 확인합니다.
    CIPHERS=$(grep "^Ciphers" $SSHD_CONFIG | awk '{print $2}')
    MACS=$(grep "^MACs" $SSHD_CONFIG | awk '{print $2}')

    # 설정값이 비어 있지 않은지 확인합니다.
    if [ -n "$CIPHERS" ] && [ -n "$MACS" ]; then
        echo "양호: SSH 서비스에서 데이터의 디지털 암호화 및 서명 기능이 활성화되어 있습니다." >> $TMP1
    else
        echo "취약: SSH 서비스에서 데이터의 디지털 암호화 또는 서명 기능이 적절히 설정되지 않았습니다." >> $TMP1
    fi
else
    echo "정보: SSH 서비스 설정 파일($SSHD_CONFIG)이 존재하지 않습니다." >> $TMP1
fi

# 결과 파일 출력
cat $TMP1
echo
