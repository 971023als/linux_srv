#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="시스템 관리"
code="SRV-004"
riskLevel="중"
diagnosisItem="SMTP 서비스 상태 검사"
diagnosisResult=""
status=""

BAR

diagnosisItem="불필요한 SMTP 서비스 실행"

# SMTP 서비스 (예: postfix)가 실행 중인지 확인합니다.
SMTP_SERVICE="postfix"

if systemctl is-active --quiet $SMTP_SERVICE; then
    diagnosisResult="$SMTP_SERVICE 서비스가 실행 중입니다."
    status="취약"
else
    diagnosisResult="$SMTP_SERVICE 서비스가 비활성화되어 있거나 실행 중이지 않습니다."
    status="양호"
fi

# Additional check for SMTP service on port 25
SMTP_PORT_STATUS=$(ss -tuln | grep -q ':25 ' && echo "OPEN" || echo "CLOSED")

if [ "$SMTP_PORT_STATUS" = "OPEN" ]; then
    diagnosisResult="$diagnosisResult SMTP 포트(25)가 열려 있습니다. 불필요한 서비스가 실행 중일 수 있습니다."
    status="취약"
else
    diagnosisResult="$diagnosisResult SMTP 포트(25)는 닫혀 있습니다."
fi

# Write the result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

BAR

cat $OUTPUT_CSV
echo ; echo
