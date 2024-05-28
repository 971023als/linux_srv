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
[양호]: SNMP 서비스가 비활성화되어 있는 경우
[취약]: SNMP 서비스가 활성화되어 있는 경우
EOF

BAR

# Set diagnostic variables
category="서비스 관리"
code="SRV-147"
riskLevel="중"
diagnosisItem="불필요한 SNMP 서비스 실행"
service="Account Management"
diagnosisResult=""
status=""

if [ $(ps -ef | grep -i 'snmp' | grep -v 'grep' | wc -l) -gt 0 ]; then
    diagnosisResult="SNMP 서비스를 사용하고 있습니다."
    status="취약"
    log_result "WARN" "$diagnosisResult"
else
    diagnosisResult="※ U-66 결과 : 양호(Good)"
    status="양호"
    log_result "OK" "$diagnosisResult"
fi

# Append result to CSV
append_to_csv "$category" "$code" "$riskLevel" "$diagnosisItem" "$service" "$diagnosisResult" "$status"

# Display the results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
