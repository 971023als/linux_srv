#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="보안관리"
code="SRV-003"
riskLevel="중"
diagnosisItem="SNMP 접근 통제 설정 검사"
diagnosisResult=""
status=""

BAR

diagnosisItem="SNMP 접근 통제 미설정"

# SNMPD 설정 파일 경로
SNMPD_CONF="/etc/snmp/snmpd.conf"
ACCESS_CONTROL_STRING="com2sec"

# SNMPD 설정 파일에서 com2sec가 적절하게 설정되었는지 확인합니다
if [ -f "$SNMPD_CONF" ]; then
    if grep -q "^$ACCESS_CONTROL_STRING" "$SNMPD_CONF"; then
        diagnosisResult="SNMP 접근 제어가 적절하게 설정됨"
        status="양호"
    else
        diagnosisResult="SNMP 접근 제어가 설정되지 않음"
        status="취약"
    fi
else
    diagnosisResult="SNMP 구성 파일($SNMPD_CONF)을 찾을 수 없음"
    status="취약"
fi

# Write the result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

BAR

cat $OUTPUT_CSV
echo ; echo
