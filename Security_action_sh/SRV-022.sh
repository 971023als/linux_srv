#!/bin/bash

. function.sh

TMP1=$(basename "$0").log
> $TMP1

BAR

echo "[SRV-022] 계정의 비밀번호 설정 및 빈 암호 사용 관리 조치" >> $TMP1

# /etc/shadow 파일을 확인하여 빈 비밀번호가 설정된 계정을 찾고, 비밀번호를 설정합니다.
while IFS=: read -r user enc_passwd rest; do
    if [[ "$enc_passwd" == "" || "$enc_passwd" == "!" || "$enc_passwd" == "*" ]]; then
        # 비밀번호를 설정하는 명령어 예시: passwd $user
        # 실제 사용 시에는 안전한 방법으로 비밀번호를 설정하거나 관리자에게 알림을 보내야 합니다.
        echo "WARN: $user 계정에 비밀번호가 설정되지 않았습니다. 관리자가 비밀번호를 설정해야 합니다." >> $TMP1
        # passwd --lock $user # 계정 잠금을 해제하고 비밀번호를 설정하려면 이 주석을 해제하고 적절한 비밀번호 설정 명령을 추가하세요.
    fi
done < /etc/shadow

BAR

# 최종 결과를 출력합니다.
cat $TMP1

echo ; echo
