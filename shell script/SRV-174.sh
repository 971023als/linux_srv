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

CODE [SRV-174] 불필요한 DNS 서비스 실행

cat << EOF >> $TMP1
[양호]: DNS 서비스가 비활성화되어 있는 경우
[취약]: DNS 서비스가 활성화되어 있는 경우
EOF

BAR

# Define security details
category="네트워크 보안"
code="SRV-174"
riskLevel="중"
diagnosisItem="DNS 서비스 실행 상태 검사"
diagnosisResult=""
status=""

# DNS 서비스 상태 확인 (named 서비스 예시)
dns_service_status=$(systemctl is-active named)

if [ "$dns_service_status" == "active" ]; then
    diagnosisResult="취약"
    status="WARN"
    log_result "WARN" "DNS 서비스(named)가 활성화되어 있습니다."
else
    diagnosisResult="양호"
    status="OK"
    log_result "OK" "DNS 서비스(named)가 비활성화되어 있습니다."
fi

# Append result to CSV
append_to_csv "$category" "$code" "$riskLevel" "$diagnosisItem" "$diagnosisResult" "$status"

# Display the results
cat $TMP1

echo ; echo