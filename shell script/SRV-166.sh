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

CODE [SRV-166] 불필요한 숨김 파일 또는 디렉터리 존재

cat << EOF >> $TMP1
[양호]: 불필요한 숨김 파일 또는 디렉터리가 존재하지 않는 경우
[취약]: 불필요한 숨김 파일 또는 디렉터리가 존재하는 경우
EOF

BAR

# Define security details
category="시스템 보안"
code="SRV-166"
riskLevel="낮음"
diagnosisItem="불필요한 숨김 파일 또는 디렉터리 존재"
diagnosisResult=""
status=""

# 시스템에서 숨김 파일 및 디렉터리 검색
hidden_files=$(find / -name ".*" -type f 2>/dev/null)
hidden_dirs=$(find / -name ".*" -type d 2>/dev/null)

if [ -z "$hidden_files" ] && [ -z "$hidden_dirs" ]; then
    diagnosisResult="양호"
    status="OK"
    log_result "OK" "불필요한 숨김 파일 또는 디렉터리가 존재하지 않습니다."
else
    diagnosisResult="취약"
    status="WARN"
    log_result "WARN" "다음의 불필요한 숨김 파일 또는 디렉터리가 존재합니다: $hidden_files $hidden_dirs"
fi

# Append result to CSV
append_to_csv "$category" "$code" "$riskLevel" "$diagnosisItem" "$diagnosisResult" "$status"

# Display the results
cat $TMP1

echo ; echo
