#!/bin/bash

# DNS Zone Transfer 제한 설정 스크립트
TMP1=$(SCRIPTNAME).log
> $TMP1

echo "DNS Zone Transfer 설정 점검 및 조치 시작..." >> $TMP1

DNS_CONFIG_FILE="/etc/named.conf"  # BIND DNS 서버의 기본 설정 파일

# DNS 서비스 실행 여부 확인
ps_dns_count=$(ps -ef | grep -i 'named' | grep -v 'grep' | wc -l)
if [ $ps_dns_count -gt 0 ]; then
    # /etc/named.conf 파일 존재 여부 확인
    if [ -f $DNS_CONFIG_FILE ]; then
        # allow-transfer 설정 확인 및 수정
        allow_transfer_exists=$(grep -E "allow-transfer" $DNS_CONFIG_FILE)
        if [[ $allow_transfer_exists == *"any;"* ]]; then
            # allow-transfer { any; } 설정을 안전한 설정으로 변경
            sed -i "/allow-transfer { any; }/d" $DNS_CONFIG_FILE
            echo "allow-transfer 설정을 제거하고, 안전한 ACL로 대체하는 작업이 필요합니다." >> $TMP1
        else
            echo "allow-transfer 설정이 이미 안전하게 구성되어 있습니다." >> $TMP1
        fi
    else
        echo "/etc/named.conf 파일이 존재하지 않습니다. DNS 서비스 구성 파일을 확인하세요." >> $TMP1
    fi
else
    echo "DNS 서비스(named)가 실행 중이지 않습니다." >> $TMP1
fi

echo "DNS Zone Transfer 설정 점검 및 조치 완료." >> $TMP1
cat "$TMP1"
echo ; echo
