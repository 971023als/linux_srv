#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="시스템 관리"
code="SRV-034"
riskLevel="중"
diagnosisItem="불필요한 서비스 활성화 검사"
diagnosisResult=""
status=""

BAR

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 불필요한 서비스가 비활성화된 경우
[취약]: 불필요한 서비스가 활성화된 경우
EOF

BAR

r_command=("rsh" "rlogin" "rexec" "shell" "login" "exec")
service_active=false

# Check /etc/xinetd.d for unnecessary services
if [ -d /etc/xinetd.d ]; then
    for cmd in "${r_command[@]}"; do
        if [ -f /etc/xinetd.d/$cmd ]; then
            if ! grep -q 'disable[[:space:]]*=[[:space:]]*yes' /etc/xinetd.d/$cmd; then
                diagnosisResult="불필요한 $cmd 서비스가 실행 중입니다."
                status="취약"
                echo "WARN: $diagnosisResult" >> $TMP1
                service_active=true
                break
            fi
        fi
    done
fi

# Check /etc/inetd.conf for unnecessary services
if [ "$service_active" = false ] && [ -f /etc/inetd.conf ]; then
    for cmd in "${r_command[@]}"; do
        if grep -qvE '^#' /etc/inetd.conf | grep -q "$cmd"; then
            diagnosisResult="불필요한 $cmd 서비스가 실행 중입니다."
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
            service_active=true
            break
        fi
    done
fi

# If no unnecessary services are found active
if [ "$service_active" = false ]; then
    diagnosisResult="불필요한 서비스가 비활성화된 경우"
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
fi

# Write the final result to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

BAR

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
