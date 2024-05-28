#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

CODE [SRV-147] 불필요한 SNMP 서비스 실행

cat << EOF >> $TMP1
[양호]: SNMP 서비스가 비활성화되어 있는 경우
[취약]: SNMP 서비스가 활성화되어 있는 경우
EOF

BAR

# SNMP 서비스 상태 확인 및 비활성화
if systemctl is-active --quiet snmpd; then
    WARN "SNMP 서비스를 사용하고 있습니다. 비활성화를 시도합니다." >> $TMP1
    systemctl stop snmpd
    systemctl disable snmpd
    if systemctl is-active --quiet snmpd; then
        WARN "SNMP 서비스 비활성화에 실패했습니다." >> $TMP1
    else
        OK "SNMP 서비스가 성공적으로 비활성화되었습니다." >> $TMP1
    fi
else
    OK "※ U-66 결과 : 양호(Good)" >> $TMP1
fi

cat $TMP1

echo ; echo
