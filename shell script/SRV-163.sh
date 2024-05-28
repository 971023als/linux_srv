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

CODE [SRV-163] 시스템 사용 주의사항 미출력

cat << EOF >> $TMP1
[양호]: 시스템 로그온 시 사용 주의사항이 출력되는 경우
[취약]: 시스템 로그온 시 사용 주의사항이 출력되지 않는 경우
EOF

BAR

# Define security details
category="시스템 보안"
code="SRV-163"
riskLevel="중"
diagnosisItem="시스템 사용 주의사항 미출력"
diagnosisResult=""
status=""

# Check /etc/motd file
motd_file="/etc/motd"
issue_file="/etc/issue"

motd_exists=false
issue_exists=false

if [ -f "$motd_file" ] && [ -s "$motd_file" ]; then
    motd_exists=true
    log_result "OK" "/etc/motd 파일이 존재하며 내용이 있습니다."
else
    log_result "WARN" "/etc/motd 파일이 존재하지 않거나 비어 있습니다."
fi

# Check /etc/issue file
if [ -f "$issue_file" ] && [ -s "$issue_file" ]; then
    issue_exists=true
    log_result "OK" "/etc/issue 파일이 존재하며 내용이 있습니다."
else
    log_result "WARN" "/etc/issue 파일이 존재하지 않거나 비어 있습니다."
fi

# Determine overall status
if $motd_exists && $issue_exists; then
    diagnosisResult="양호"
    status="OK"
else
    diagnosisResult="취약"
    status="WARN"
fi

# Append result to CSV
append_to_csv "$category" "$code" "$riskLevel" "$diagnosisItem" "$diagnosisResult" "$status"

# Display the results
cat $TMP1

echo ; echo

