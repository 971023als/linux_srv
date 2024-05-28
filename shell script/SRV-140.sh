#!/bin/bash

# Source the function script
. function.sh

# Initialize CSV file
CSV_FILE="output.csv"
if [ ! -f $CSV_FILE ]; then
    echo "Category,Code,Risk Level,Diagnosis Item,Service,Diagnosis Result,Status" > $CSV_FILE
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
  echo "$category,$code,$risk_level,$diagnosis_item,$service,$diagnosis_result,$status" >> $CSV_FILE
}

# Function to log results
log_result() {
  local type=$1
  local message=$2
  echo "$type $message" >> $TMP1
}

BAR

# Set diagnostic variables
category="보안 정책"
code="SRV-140"
risk_level="중"
diagnosis_item="이동식 미디어 포맷 및 꺼내기 허용 정책"
service="Account Management"
diagnosis_result=""
status=""

# Initialize result file
TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 이동식 미디어의 포맷 및 꺼내기에 대한 사용 정책이 적절하게 설정되어 있는 경우
[취약]: 이동식 미디어의 포맷 및 꺼내기에 대한 사용 정책이 설정되어 있지 않은 경우
EOF

BAR

# dconf를 사용하여 GNOME 환경 설정 확인
if command -v dconf >/dev/null; then
    media_automount=$(dconf read /org/gnome/desktop/media-handling/automount)
    media_automount_open=$(dconf read /org/gnome/desktop/media-handling/automount-open)
    
    if [[ "$media_automount" == "false" && "$media_automount_open" == "false" ]]; then
        diagnosis_result="이동식 미디어의 자동 마운트 및 열기가 비활성화되어 있습니다."
        status="양호"
        log_result "OK" "$diagnosis_result"
    else
        diagnosis_result="이동식 미디어의 자동 마운트 또는 열기가 활성화되어 있습니다."
        status="취약"
        log_result "WARN" "$diagnosis_result"
    fi
else
    diagnosis_result="dconf 도구가 설치되어 있지 않거나 GNOME 환경이 아닙니다."
    status="N/A"
    log_result "INFO" "$diagnosis_result"
fi

# Append result to CSV
append_to_csv "$category" "$code" "$risk_level" "$diagnosis_item" "$service" "$diagnosis_result" "$status"

# Display the results
cat $TMP1

echo ; echo

cat $CSV_FILE
