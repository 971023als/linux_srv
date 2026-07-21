#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="$(basename "$0" .sh).csv"
echo "Category,Code,Risk Level,Diagnosis Item,DiagnosisResult,Status" > $CSV_FILE

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

# Function to log results
log_result() {
  local type=$1
  local message=$2
  echo "$type $message" >> $TMP1
}

# Initialize log file
TMP1="$(basename "$0" .sh).log"
> $TMP1

BAR

CODE="SRV-150"
diagnosisItem="로컬 로그온 허용"

cat << EOF >> $TMP1
[양호]: 로컬 로그온이 비활성화된 경우
[취약]: 로컬 로그온이 활성화된 경우
EOF

BAR

# Define security details
category="시스템 접근 보안"
code="SRV-150"
riskLevel="중"
diagnosisItem="로컬 로그온 허용"
diagnosisResult=""
status=""

# SRV-150: 로컬 로그온 허용 - Windows 전용 항목, Linux 환경에서는 N/A
diagnosisResult="Linux 환경에서 해당 없음 (N/A)"
status="N/A"
log_result "N/A" "로컬 로그온 정책은 Linux 환경에서 적용되지 않습니다."

# Append result to CSV
append_to_csv "$category" "$code" "$riskLevel" "$diagnosisItem" "$diagnosisResult" "$status"

# Display the results
cat $TMP1

echo ; echo
