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
CODE="U-91"
RISK_LEVEL="중"
DIAGNOSIS_ITEM="불필요하게 SUID, SGID 비트가 설정된 파일 존재"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: SUID 및 SGID 비트가 필요하지 않은 파일에 설정되지 않은 경우
[취약]: SUID 및 SGID 비트가 필요하지 않은 파일에 설정된 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,$result,$status" >> $CSV_FILE
}

# SUID 또는 SGID 비트가 설정된 파일 검색
suid_files=$(find / -perm /4000 -type f 2>/dev/null)
sgid_files=$(find / -perm /2000 -type f 2>/dev/null)

# SUID 파일 확인
if [ -z "$suid_files" ]; then
    DiagnosisResult="SUID 비트가 설정된 불필요한 파일이 없습니다."
    Status="양호"
    append_to_csv "$DiagnosisResult" "$Status"
    echo "OK: $DiagnosisResult" >> $TMP1
else
    DiagnosisResult="SUID 비트가 설정된 불필요한 파일이 있습니다: $suid_files"
    Status="취약"
    append_to_csv "$DiagnosisResult" "$Status"
    echo "WARN: $DiagnosisResult" >> $TMP1
fi

# SGID 파일 확인
if [ -z "$sgid_files" ]; then
    DiagnosisResult="SGID 비트가 설정된 불필요한 파일이 없습니다."
    Status="양호"
    append_to_csv "$DiagnosisResult" "$Status"
    echo "OK: $DiagnosisResult" >> $TMP1
else
    DiagnosisResult="SGID 비트가 설정된 불필요한 파일이 있습니다: $sgid_files"
    Status="취약"
    append_to_csv "$DiagnosisResult" "$Status"
    echo "WARN: $DiagnosisResult" >> $TMP1
fi

cat $TMP1

echo ; echo

cat $CSV_FILE

echo "CSV report generated: $CSV_FILE"
echo ; echo
