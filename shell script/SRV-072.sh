#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="$(basename "$0" .sh).csv"
if [ ! -f $CSV_FILE ]; then
    echo "Category,Code,Risk Level,Diagnosis Item,DiagnosisResult,Status" > $CSV_FILE
fi

BAR

CATEGORY="네트워크 보안"
CODE="SRV-072"
RISK_LEVEL="중"
DIAGNOSIS_ITEM="기본 관리자 계정명(Administrator) 존재"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 기본 'Administrator' 계정이 존재하지 않는 경우
[취약]: 기본 'Administrator' 계정이 존재하는 경우
EOF

BAR

# 'Administrator' 계정 확인
if grep -qi "Administrator" /etc/passwd; then
    DiagnosisResult="기본 'Administrator' 계정이 존재합니다."
    Status="취약"
    echo "WARN: $DiagnosisResult" >> $TMP1
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,$DiagnosisResult,$Status" >> $CSV_FILE
else
    DiagnosisResult="기본 'Administrator' 계정이 존재하지 않습니다."
    Status="양호"
    echo "OK: $DiagnosisResult" >> $TMP1
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,$DiagnosisResult,$Status" >> $CSV_FILE
fi

cat $TMP1

echo "CSV report generated: $CSV_FILE"
echo ; echo
cat $CSV_FILE
