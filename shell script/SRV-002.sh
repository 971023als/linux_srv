#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="보안관리"
code="SRV-002"
riskLevel="상"
diagnosisItem="SNMP Set Community 스트링 검사"
diagnosisResult=""
status=""

BAR

diagnosisItem="SNMP 서비스 Set Community 스트링 설정 오류"

# SNMP service running check
ps_snmp_count=$(ps -ef | grep -i 'snmp' | grep -v 'grep' | wc -l)

if [ $ps_snmp_count -gt 0 ]; then
    # Check SNMP configuration file for Set Community string
    snmpdconf_file="/etc/snmp/snmpd.conf" # Default path for Linux; adjust for other OS as needed
    if [ -f "$snmpdconf_file" ]; then
        # Check for "public" or "private" strings being used
        if grep -qiE 'public|private' $snmpdconf_file; then
            diagnosisResult="기본 SNMP Set Community 스트링(public/private)이 사용됨"
            status="취약"
        else
            diagnosisResult="기본 SNMP Set Community 스트링(public/private)이 사용되지 않음"
            status="양호"
        fi
    else
        diagnosisResult="SNMP 구성 파일($snmpdconf_file)을 찾을 수 없음"
        status="취약"
    fi
else
    diagnosisResult="SNMP 서비스가 실행 중이지 않습니다."
    status="양호"
fi

# Write the result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

BAR

cat $OUTPUT_CSV
echo ; echo
