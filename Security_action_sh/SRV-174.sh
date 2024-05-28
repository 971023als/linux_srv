#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

CODE [SRV-174] 불필요한 DNS 서비스 실행

echo "DNS 서비스(named)의 상태를 확인합니다..."

# DNS 서비스 상태 확인
dns_service_status=$(systemctl is-active named)

if [ "$dns_service_status" == "active" ]; then
    echo "DNS 서비스(named)가 활성화되어 있습니다."
    read -p "DNS 서비스(named)를 비활성화하시겠습니까? (y/n): " user_decision

    if [ "$user_decision" == "y" ]; then
        # DNS 서비스 비활성화
        systemctl stop named
        systemctl disable named
        echo "DNS 서비스(named)를 비활성화했습니다."
        OK "DNS 서비스(named)가 비활성화되어 있습니다." >> $TMP1
    else
        echo "DNS 서비스(named) 비활성화 작업이 취소되었습니다."
        WARN "DNS 서비스(named)가 활성화되어 있습니다." >> $TMP1
    fi
else
    echo "DNS 서비스(named)가 이미 비활성화되어 있습니다."
    OK "DNS 서비스(named)가 비활성화되어 있습니다." >> $TMP1
fi

cat $TMP1

echo ; echo
