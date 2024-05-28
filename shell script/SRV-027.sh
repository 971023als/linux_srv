#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="네트워크 보안"
code="SRV-027"
riskLevel="높음"
diagnosisItem="서비스 접근 IP 및 포트 제한 설정 검사"
diagnosisResult=""
status=""

BAR

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 서비스에 대한 IP 및 포트 접근 제한이 적절하게 설정된 경우
[취약]: 서비스에 대한 IP 및 포트 접근 제한이 설정되지 않은 경우
EOF

BAR

# Check /etc/hosts.deny for 'ALL: ALL' configuration
if [ -f /etc/hosts.deny ]; then
    etc_hostsdeny_allall_count=$(grep -vE '^#|^\s#' /etc/hosts.deny | awk '{gsub(" ", "", $0); print}' | grep -i 'all:all' | wc -l)
    if [ $etc_hostsdeny_allall_count -gt 0 ]; then
        # Check /etc/hosts.allow if /etc/hosts.deny has 'ALL: ALL'
        if [ -f /etc/hosts.allow ]; then
            etc_hostsallow_allall_count=$(grep -vE '^#|^\s#' /etc/hosts.allow | awk '{gsub(" ", "", $0); print}' | grep -i 'all:all' | wc -l)
            if [ $etc_hostsallow_allall_count -gt 0 ]; then
                diagnosisResult="/etc/hosts.allow 파일에 'ALL : ALL' 설정이 있습니다."
                status="취약"
                echo "WARN: $diagnosisResult" >> $TMP1
            else
                diagnosisResult="서비스 접근 IP 및 포트 제한이 적절하게 설정된 경우"
                status="양호"
                echo "OK: $diagnosisResult" >> $TMP1
            fi
        else
            diagnosisResult="서비스 접근 IP 및 포트 제한이 적절하게 설정된 경우"
            status="양호"
            echo "OK: $diagnosisResult" >> $TMP1
        fi
    else
        diagnosisResult="/etc/hosts.deny 파일에 'ALL : ALL' 설정이 없습니다."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    fi
else
    diagnosisResult="/etc/hosts.deny 파일이 없습니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
fi

# Write the final result to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

BAR

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
