#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="시스템 보안"
code="SRV-035"
riskLevel="상"
diagnosisItem="취약한 서비스 활성화 검사"
diagnosisResult=""
status=""

BAR

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 취약한 서비스가 비활성화된 경우
[취약]: 취약한 서비스가 활성화된 경우
EOF

BAR

vulnerable_services=("echo" "discard" "daytime" "chargen")

check_service_activation() {
    local service_file=$1
    local service_name=$2

    if [ -f "$service_file" ]; then
        local disabled_count=$(grep -vE '^#|^\s#' "$service_file" | grep -i 'disable' | grep -i 'yes' | wc -l)
        if [ $disabled_count -eq 0 ]; then
            diagnosisResult="$service_name 서비스가 ${service_file} 파일에서 실행 중입니다."
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
            echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
            cat $TMP1
            echo ; echo
            exit 0
        fi
    fi
}

# Check for vulnerable services in /etc/xinetd.d
if [ -d /etc/xinetd.d ]; then
    for service in "${vulnerable_services[@]}"; do
        check_service_activation "/etc/xinetd.d/$service" "$service"
    done
fi

# Check for vulnerable services in /etc/inetd.conf
if [ -f /etc/inetd.conf ]; then
    for service in "${vulnerable_services[@]}"; do
        if grep -vE '^#|^\s#' /etc/inetd.conf | grep -q "$service"; then
            diagnosisResult="$service 서비스가 /etc/inetd.conf 파일에서 실행 중입니다."
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
            echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
            cat $TMP1
            echo ; echo
            exit 0
        fi
    done
fi

diagnosisResult="취약한 서비스가 비활성화된 경우"
status="양호"
echo "OK: $diagnosisResult" >> $TMP1
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

BAR

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
