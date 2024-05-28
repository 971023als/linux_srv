#!/bin/bash

. function.sh

TMP1=$(basename "$0").log
> $TMP1

BAR

CODE [SRV-003] SNMP 접근 통제 미설정

cat << EOF >> $TMP1

[양호]: SNMP 접근 제어가 적절하게 설정된 경우
[취약]: SNMP 접근 제어가 설정되지 않거나 미흡한 경우

EOF

BAR

"[SRV-003] SNMP 접근 통제 미설정" >> $TMP1

SNMPD_CONF="/etc/snmp/snmpd.conf"
ACCESS_CONTROL_STRING="com2sec notConfigUser default public"

# SNMP 접근 통제가 설정되지 않은 경우 적절한 접근 통제 설정을 추가합니다
if ! grep -q "^com2sec" "$SNMPD_CONF"; then
    echo "$ACCESS_CONTROL_STRING" >> "$SNMPD_CONF"
    WARN "SNMP 접근 제어가 자동으로 설정됨: $ACCESS_CONTROL_STRING" >> $TMP1
    # SNMP 서비스 재시작 또는 리로드
    systemctl restart snmpd
else
    OK "SNMP 접근 제어가 이미 적절하게 설정됨" >> $TMP1
fi

BAR

cat $TMP1

echo ; echo
