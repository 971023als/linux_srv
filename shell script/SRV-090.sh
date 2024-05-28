#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $CSV_FILE ]; then
    echo "Category,Code,Risk Level,Diagnosis Item,DiagnosisResult,Status" > $CSV_FILE
fi

BAR

CATEGORY="시스템 보안"
CODE="SRV-090"
RISK_LEVEL="높음"
DIAGNOSIS_ITEM="원격 레지스트리 서비스 활성화 검사"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 원격 레지스트리 서비스가 비활성화되어 있는 경우
[취약]: 원격 레지스트리 서비스가 활성화되어 있는 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,$result,$status" >> $CSV_FILE
}

# 원격 레지스트리 서비스 상태 확인
if systemctl is-active --quiet remote-registry; then
    DiagnosisResult="원격 레지스트리 서비스가 활성화되어 있습니다."
    Status="취약"
    append_to_csv "$DiagnosisResult" "$Status"
    echo "WARN: $DiagnosisResult" >> $TMP1
else
    DiagnosisResult="원격 레지스트리 서비스가 비활성화되어 있습니다."
    Status="양호"
    append_to_csv "$DiagnosisResult" "$Status"
    echo "OK: $DiagnosisResult" >> $TMP1
fi

cat $TMP1

echo ; echo

cat $CSV_FILE

echo "CSV report generated: $CSV_FILE"
echo ; echo
