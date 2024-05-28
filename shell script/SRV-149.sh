#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="$(basename "$0" .sh).csv"
echo "Category,Code,Risk Level,Diagnosis Item,Diagnosis Result,Status" > $CSV_FILE

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
  echo "$type: $message" >> $TMP1
}

# Initialize log file
TMP1="$(basename "$0" .sh).log"
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 모든 디스크 볼륨이 암호화되어 있는 경우
[취약]: 하나 이상의 디스크 볼륨이 암호화되지 않은 경우
EOF

BAR

# Set diagnostic variables
category="시스템 관리"
code="SRV-149"
riskLevel="상"
diagnosisItem="디스크 볼륨 암호화 미적용"
diagnosisResult=""
status=""

# 암호화된 디스크 볼륨 확인
encrypted_volumes=$(lsblk -o NAME,TYPE,MOUNTPOINT,SIZE,STATE | grep 'crypt')

if [ -z "$encrypted_volumes" ]; then
    diagnosisResult="암호화된 디스크 볼륨이 존재하지 않습니다."
    status="취약"
    log_result "WARN" "$diagnosisResult"
else
    diagnosisResult="다음의 암호화된 디스크 볼륨이 존재합니다: $encrypted_volumes"
    status="양호"
    log_result "OK" "$diagnosisResult"
fi

# Append result to CSV
append_to_csv "$category" "$code" "$riskLevel" "$diagnosisItem" "$diagnosisResult" "$status"

# Display the results
cat $TMP1

echo ; echo

cat $CSV_FILE
