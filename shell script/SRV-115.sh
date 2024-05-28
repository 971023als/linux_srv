#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $CSV_FILE ]; then
    echo "Category,Code,Risk Level,Diagnosis Item,DiagnosisResult,Status" > $CSV_FILE
fi

BAR

CATEGORY="로그 관리"
CODE="SRV-115"
RISK_LEVEL="중"
DIAGNOSIS_ITEM="로그의 정기적 검토 및 보고 미수행"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 로그가 정기적으로 검토 및 보고되고 있는 경우
[취약]: 로그가 정기적으로 검토 및 보고되지 않는 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,$result,$status" >> $CSV_FILE
}

# Check for the existence of the log review and reporting script
log_review_script="/path/to/log/review/script"
if [ ! -f "$log_review_script" ]; then
  DiagnosisResult="로그 검토 및 보고 스크립트가 존재하지 않습니다."
  Status="취약"
  append_to_csv "$DiagnosisResult" "$Status"
  echo "WARN: $DiagnosisResult" >> $TMP1
else
  DiagnosisResult="로그 검토 및 보고 스크립트가 존재합니다."
  Status="양호"
  append_to_csv "$DiagnosisResult" "$Status"
  echo "OK: $DiagnosisResult" >> $TMP1
fi

# Check for the existence of the log report
log_report="/path/to/log/report"
if [ ! -f "$log_report" ]; then
  DiagnosisResult="로그 보고서가 존재하지 않습니다."
  Status="취약"
  append_to_csv "$DiagnosisResult" "$Status"
  echo "WARN: $DiagnosisResult" >> $TMP1
else
  DiagnosisResult="로그 보고서가 존재합니다."
  Status="양호"
  append_to_csv "$DiagnosisResult" "$Status"
  echo "OK: $DiagnosisResult" >> $TMP1
fi

cat $TMP1

echo ; echo

cat $CSV_FILE

echo "CSV report generated: $CSV_FILE"
echo ; echo
