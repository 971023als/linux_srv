#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="output.csv"
if [ ! -f $CSV_FILE ]; then
    echo "Category,Code,Risk Level,Diagnosis Item,DiagnosisResult,Status" > $CSV_FILE
fi

BAR

CATEGORY="시스템 보안"
CODE="SRV-134"
RISK_LEVEL="높음"
DIAGNOSIS_ITEM="스택 영역 실행 방지 설정 검사"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 스택 영역 실행 방지가 활성화된 경우
[취약]: 스택 영역 실행 방지가 비활성화된 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local category=$1
    local code=$2
    local risk_level=$3
    local diagnosis_item=$4
    local diagnosis_result=$5
    local status=$6
    echo "$category,$code,$risk_level,$diagnosis_item,$diagnosis_result,$status" >> $CSV_FILE
}

# 스택 영역 실행 방지 설정 확인
if grep -q "kernel.randomize_va_space=2" /etc/sysctl.conf; then
    result="스택 영역 실행 방지가 활성화되어 있습니다."
    OK "$result" >> $TMP1
    append_to_csv "$CATEGORY" "$CODE" "$RISK_LEVEL" "$DIAGNOSIS_ITEM" "$result" "양호"
else
    result="스택 영역 실행 방지가 비활성화되어 있습니다."
    WARN "$result" >> $TMP1
    append_to_csv "$CATEGORY" "$CODE" "$RISK_LEVEL" "$DIAGNOSIS_ITEM" "$result" "취약"
fi

cat $TMP1

echo ; echo

cat $CSV_FILE

echo "CSV report generated: $CSV_FILE"
echo ; echo
