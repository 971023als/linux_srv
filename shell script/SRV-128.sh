#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="output.csv"
if [ ! -f $CSV_FILE ]; then
    echo "Category,Code,Risk Level,Diagnosis Item,DiagnosisResult,Status" > $CSV_FILE
fi

BAR

CATEGORY="시스템 보안"
CODE="SRV-128"
RISK_LEVEL="낮음"
DIAGNOSIS_ITEM="NTFS 파일 시스템 사용 여부 검사"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: NTFS 파일 시스템이 사용되지 않는 경우
[취약]: NTFS 파일 시스템이 사용되는 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,$SERVICE,$result,$status" >> $CSV_FILE
}

# NTFS 파일 시스템 사용 여부 확인
ntfs_check=$(mount | grep 'type ntfs')

if [ -z "$ntfs_check" ]; then
    DiagnosisResult="NTFS 파일 시스템이 사용되지 않습니다."
    Status="양호"
    OK "NTFS 파일 시스템이 사용되지 않습니다."
else
    DiagnosisResult="NTFS 파일 시스템이 사용되고 있습니다: $ntfs_check"
    Status="취약"
    WARN "NTFS 파일 시스템이 사용되고 있습니다: $ntfs_check"
fi

append_to_csv "$DiagnosisResult" "$Status"

cat $TMP1

echo ; echo

cat $CSV_FILE

echo "CSV report generated: $CSV_FILE"
echo ; echo
