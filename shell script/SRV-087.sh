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
CODE="SRV-087"
RISK_LEVEL="중"
DIAGNOSIS_ITEM="C 컴파일러 존재 및 권한 설정"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: C 컴파일러가 존재하지 않거나, 적절한 권한으로 설정된 경우
[취약]: C 컴파일러가 존재하며 권한 설정이 미흡한 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,$result,$status" >> $CSV_FILE
}

# C 컴파일러 위치 확인
COMPILER_PATH=$(which gcc)

# 컴파일러 존재 여부 및 권한 확인
if [ -z "$COMPILER_PATH" ]; then
    DiagnosisResult="C 컴파일러(gcc)가 시스템에 설치되어 있지 않습니다."
    Status="양호"
    append_to_csv "$DiagnosisResult" "$Status"
    echo "INFO: $DiagnosisResult" >> $TMP1
else
    # 권한 확인
    COMPILER_PERMS=$(stat -c "%a" "$COMPILER_PATH")
    if [ "$COMPILER_PERMS" -le "755" ]; then
        DiagnosisResult="C 컴파일러(gcc)의 권한이 적절합니다. 권한: $COMPILER_PERMS"
        Status="양호"
        append_to_csv "$DiagnosisResult" "$Status"
        echo "OK: $DiagnosisResult" >> $TMP1
    else
        DiagnosisResult="C 컴파일러(gcc)의 권한이 부적절합니다. 권한: $COMPILER_PERMS"
        Status="취약"
        append_to_csv "$DiagnosisResult" "$Status"
        echo "WARN: $DiagnosisResult" >> $TMP1
    fi
fi

cat $TMP1

echo ; echo

cat $CSV_FILE

echo "CSV report generated: $CSV_FILE"
echo ; echo
