#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

CODE [SRV-173] DNS 서비스의 취약한 동적 업데이트 설정

echo "DNS 서비스의 동적 업데이트 설정을 확인합니다..."

# DNS 설정 파일 경로
dns_config="/etc/bind/named.conf"

# 동적 업데이트 설정 확인
if [ -f "$dns_config" ]; then
    dynamic_updates=$(grep "allow-update" "$dns_config")
    if [ -z "$dynamic_updates" ]; then
        echo "DNS 동적 업데이트가 안전하게 구성되어 있습니다."
        OK "DNS 동적 업데이트가 안전하게 구성되어 있습니다." >> $TMP1
    else
        echo "DNS 동적 업데이트 설정이 취약합니다: $dynamic_updates"
        read -p "동적 업데이트 설정을 제거(안전하게 수정)하시겠습니까? (y/n): " user_decision
        
        if [ "$user_decision" == "y" ]; then
            # 동적 업데이트 설정 제거
            sed -i '/allow-update/d' "$dns_config"
            echo "DNS 동적 업데이트 설정을 안전하게 수정했습니다."
            OK "DNS 동적 업데이트가 안전하게 수정되었습니다." >> $TMP1
        else
            echo "동적 업데이트 설정 수정 작업이 취소되었습니다."
            WARN "DNS 동적 업데이트 설정이 취약합니다." >> $TMP1
        fi
    fi
else
    echo "DNS 설정 파일이 존재하지 않습니다."
    INFO "DNS 설정 파일이 존재하지 않습니다." >> $TMP1
fi

cat $TMP1

echo ; echo
