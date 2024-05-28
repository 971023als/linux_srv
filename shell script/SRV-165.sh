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

CODE [SRV-165] 불필요하게 Shell이 부여된 계정 존재

cat << EOF >> $TMP1
[양호]: 불필요하게 Shell이 부여된 계정이 존재하지 않는 경우
[취약]: 불필요하게 Shell이 부여된 계정이 존재하는 경우
EOF

BAR

# Define security details
category="시스템 접근 제어"
code="SRV-165"
riskLevel="높음"
diagnosisItem="불필요하게 Shell이 부여된 계정 존재"
diagnosisResult=""
status=""

# Check for unnecessary accounts with shell access
if [ -f /etc/passwd ]; then
  unnecessary_accounts=$(grep -E '^(daemon|bin|sys|adm|listen|nobody|nobody4|noaccess|diag|operator|gopher|games|ftp|apache|httpd|www-data|mysql|mariadb|postgres|mail|postfix|news|lp|uucp|nuucp):' /etc/passwd | awk -F : '$7!="/bin/false" && $7!="/sbin/nologin" {print}')
  if [ -n "$unnecessary_accounts" ]; then
    diagnosisResult="취약"
    status="WARN"
    log_result "WARN" "로그인이 필요하지 않은 불필요한 계정에 /bin/false 또는 /sbin/nologin 쉘이 부여되지 않았습니다."
  else
    diagnosisResult="양호"
    status="OK"
    log_result "OK" "※ U-53 결과 : 양호(Good)"
  fi
else
  diagnosisResult="취약"
  status="WARN"
  log_result "WARN" "/etc/passwd 파일이 존재하지 않습니다."
fi

# Append result to CSV
append_to_csv "$category" "$code" "$riskLevel" "$diagnosisItem" "$diagnosisResult" "$status"

# Display the results
cat $TMP1

echo ; echo
