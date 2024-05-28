#!/bin/bash

. function.sh

# Initialize CSV file
OUTPUT_CSV="output.csv"
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Function to append results to CSV file
append_to_csv() {
  local category=$1
  local code=$2
  local risk_level=$3
  local diagnosis_item=$4
  local service=$5
  local diagnosis_result=$6
  local status=$7
  echo "$category,$code,$risk_level,$diagnosis_item,$service,$diagnosis_result,$status" >> $OUTPUT_CSV
}

# Function to log results
log_result() {
  local type=$1
  local message=$2
  echo "$type $message" >> $TMP1
}

# Initialize log file
TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: /dev 경로에 불필요한 파일이 존재하지 않는 경우
[취약]: /dev 경로에 불필요한 파일이 존재하는 경우
EOF

BAR

# Set diagnostic variables
category="시스템 관리"
code="SRV-144"
riskLevel="상"
diagnosisItem="/dev 경로에 불필요한 파일 존재"
service="Account Management"
diagnosisResult=""
status=""

if [ $(find /dev -type f 2>/dev/null | wc -l) -gt 0 ]; then
    diagnosisResult="/dev 디렉터리에 존재하지 않는 device 파일이 존재합니다."
    status="취약"
    log_result "WARN" "$diagnosisResult"
else
    diagnosisResult="※ U-16 결과 : 양호(Good)"
    status="양호"
    log_result "OK" "$diagnosisResult"
fi

# Append result to CSV
append_to_csv "$category" "$code" "$riskLevel" "$diagnosisItem" "$service" "$diagnosisResult" "$status"

# Display the results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
