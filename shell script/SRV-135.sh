#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="output.csv"
if [ ! -f $CSV_FILE ]; then
    echo "Category,Code,Risk Level,Diagnosis Item,DiagnosisResult,Status" > $CSV_FILE
fi

BAR

CATEGORY="시스템 보안"
CODE="SRV-135"
RISK_LEVEL="높음"
DIAGNOSIS_ITEM="TCP 보안 설정 검사"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 필수 TCP 보안 설정이 적절히 구성된 경우
[취약]: 필수 TCP 보안 설정이 구성되지 않은 경우
EOF

BAR

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

# TCP 보안 관련 설정 확인
tcp_settings=(
  "net.ipv4.tcp_syncookies"
  "net.ipv4.tcp_max_syn_backlog"
  "net.ipv4.tcp_synack_retries"
  "net.ipv4.tcp_syn_retries"
)

all_good=true

for setting in "${tcp_settings[@]}"; do
  value=$(sysctl -n $setting 2>/dev/null)
  if [ -z "$value" ]; then
    diagnosis_result="$setting 설정이 없습니다."
    WARN "$diagnosis_result" >> $TMP1
    append_to_csv "$CATEGORY" "$CODE" "$RISK_LEVEL" "$DIAGNOSIS_ITEM" "$diagnosis_result" "취약"
    all_good=false
  else
    diagnosis_result="$setting 설정이 존재합니다: $value"
    OK "$diagnosis_result" >> $TMP1
    append_to_csv "$CATEGORY" "$CODE" "$RISK_LEVEL" "$DIAGNOSIS_ITEM" "$diagnosis_result" "양호"
  fi
done

if $all_good; then
  diagnosis_result="모든 TCP 보안 설정이 적절히 구성되었습니다."
  OK "$diagnosis_result" >> $TMP1
else
  diagnosis_result="일부 TCP 보안 설정이 누락되었습니다."
  WARN "$diagnosis_result" >> $TMP1
fi

cat $TMP1

echo ; echo

cat $CSV_FILE

echo "CSV report generated: $CSV_FILE"
echo ; echo
