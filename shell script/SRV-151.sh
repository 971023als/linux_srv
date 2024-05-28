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

CODE="SRV-151"
diagnosisItem="익명 SID/이름 변환 허용"

cat << EOF >> $TMP1
[양호]: 익명 SID/이름 변환을 허용하지 않는 경우
[취약]: 익명 SID/이름 변환을 허용하는 경우
EOF

BAR

# Set diagnostic variables
category="보안 정책"
code="SRV-151"
riskLevel="높음"
diagnosisItem="익명 SID/이름 변환 허용"
diagnosisResult=""
status=""

# 익명 SID/이름 변환 정책 확인
if secpol.exe /export /cfg secpol.cfg; then
    if grep -q "SeDenyNetworkLogonRight = *S-1-1-0" secpol.cfg; then
        diagnosisResult="익명 SID/이름 변환을 허용하지 않습니다."
        status="양호"
        log_result "OK" "익명 SID/이름 변환을 허용하지 않습니다."
    else
        diagnosisResult="익명 SID/이름 변환을 허용합니다."
        status="취약"
        log_result "WARN" "익명 SID/이름 변환을 허용합니다."
    fi
    rm secpol.cfg
else
    diagnosisResult="보안 정책 파일을 추출할 수 없습니다."
    status="취약"
    log_result "WARN" "보안 정책 파일을 추출할 수 없습니다."
fi

# Append result to CSV
append_to_csv "$category" "$code" "$riskLevel" "$diagnosisItem" "$diagnosisResult" "$status"

# Display the results
cat $TMP1

echo ; echo
