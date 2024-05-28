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

CODE [SRV-158] 불필요한 Telnet 서비스 실행

cat << EOF >> $TMP1
[양호]: Telnet 서비스가 비활성화되어 있는 경우
[취약]: Telnet 서비스가 활성화되어 있는 경우
EOF

BAR

# Define security details
category="네트워크 보안"
code="SRV-158"
riskLevel="중"
diagnosisItem="불필요한 Telnet 서비스 실행"
diagnosisResult=""
status=""

# Check if Telnet service is running
if [ -f /etc/services ]; then
  telnet_ports=($(grep -vE '^#|^\s#' /etc/services | awk 'tolower($1)=="telnet" {print $2}' | awk -F / 'tolower($2)=="tcp" {print $1}'))
  for port in "${telnet_ports[@]}"; do
    if netstat -nat 2>/dev/null | grep -w 'tcp' | grep -Ei 'listen|established|syn_sent|syn_received' | grep -q ":$port "; then
      diagnosisResult="취약"
      status="WARN"
      log_result "WARN" "Telnet 서비스가 실행 중입니다."
      append_to_csv "$category" "$code" "$riskLevel" "$diagnosisItem" "$diagnosisResult" "$status"
      cat $TMP1
      echo ; echo
      exit 0
    fi
  done
fi

# Check if Telnet process is running
if ps -ef | grep -i 'telnet' | grep -v 'grep' &> /dev/null; then
  diagnosisResult="취약"
  status="WARN"
  log_result "WARN" "Telnet 서비스가 실행 중입니다."
else
  diagnosisResult="양호"
  status="OK"
  log_result "OK" "Telnet 서비스가 실행 중이지 않습니다."
fi

# Append result to CSV
append_to_csv "$category" "$code" "$riskLevel" "$diagnosisItem" "$diagnosisResult" "$status"

# Display the results
cat $TMP1

echo ; echo