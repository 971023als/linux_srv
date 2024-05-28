#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE=$(SCRIPTNAME).csv
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
TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

CODE [SRV-173] DNS 서비스의 취약한 동적 업데이트 설정

cat << EOF >> $TMP1
[양호]: DNS 동적 업데이트가 안전하게 구성된 경우
[취약]: DNS 동적 업데이트가 취약하게 구성된 경우
EOF

BAR

# Define security details
category="네트워크 보안"
code="SRV-173"
riskLevel="중"
diagnosisItem="DNS 서비스의 취약한 동적 업데이트 설정"
diagnosisResult=""
status=""

# DNS 설정 파일 경로
dns_config="/etc/bind/named.conf"

# 동적 업데이트 설정 확인
if [ -f "$dns_config" ]; then
    dynamic_updates=$(grep "allow-update" "$dns_config")
    if [ -z "$dynamic_updates" ]; then
        diagnosisResult="양호"
        status="OK"
        log_result "OK" "DNS 동적 업데이트가 안전하게 구성되어 있습니다."
    else
        diagnosisResult="취약"
        status="WARN"
        log_result "WARN" "DNS 동적 업데이트 설정이 취약합니다: $dynamic_updates"
    fi
else
    log_result "INFO" "DNS 설정 파일이 존재하지 않습니다."
fi

# Append result to CSV
append_to_csv "$category" "$code" "$riskLevel" "$diagnosisItem" "$diagnosisResult" "$status"

# Display the results
cat $TMP1

echo ; echo