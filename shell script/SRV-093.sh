#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $CSV_FILE ]; then
    echo "Category,Code,Risk Level,Diagnosis Item,DiagnosisResult,Status" > $CSV_FILE
fi

BAR

CATEGORY="파일 시스템 보안"
CODE="SRV-093"
RISK_LEVEL="높음"
DIAGNOSIS_ITEM="불필요한 세계 쓰기 가능 파일 존재"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 시스템에 불필요한 world writable 파일이 존재하지 않는 경우
[취약]: 시스템에 불필요한 world writable 파일이 존재하는 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,$result,$status" >> $CSV_FILE
}

# Check for world writable files
world_writable_files=$(find / -type f -perm -2 2>/dev/null)

if [ -n "$world_writable_files" ]; then
    DiagnosisResult="world writable 설정이 되어있는 파일이 있습니다: $world_writable_files"
    Status="취약"
    append_to_csv "$DiagnosisResult" "$Status"
    echo "WARN: $DiagnosisResult" >> $TMP1
else
    DiagnosisResult="시스템에 불필요한 world writable 파일이 존재하지 않습니다."
    Status="양호"
    append_to_csv "$DiagnosisResult" "$Status"
    echo "OK: $DiagnosisResult" >> $TMP1
fi

cat $TMP1

echo ; echo

cat $CSV_FILE

echo "CSV report generated: $CSV_FILE"
echo ; echo
