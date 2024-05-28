#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $CSV_FILE ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $CSV_FILE
fi

BAR

CATEGORY="시스템 로깅"
CODE="SRV-108"
RISK_LEVEL="중"
DIAGNOSIS_ITEM="로그에 대한 접근통제 및 관리 미흡"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 로그 파일의 접근 통제 및 관리가 적절하게 설정되어 있는 경우
[취약]: 로그 파일의 접근 통제 및 관리가 적절하게 설정되어 있지 않은 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,$result,$status" >> $CSV_FILE
}

# Check the rsyslog configuration file
filename="/etc/rsyslog.conf"

if [ ! -e "$filename" ]; then
  DiagnosisResult="$filename 가 존재하지 않습니다"
  Status="취약"
  append_to_csv "$DiagnosisResult" "$Status"
else
  expected_content=(
    "*.info;mail.none;authpriv.none;cron.none /var/log/messages"
    "authpriv.* /var/log/secure"
    "mail.* /var/log/maillog"
    "cron.* /var/log/cron"
    "*.alert /dev/console"
    "*.emerg *"
  )

  match=0
  for content in "${expected_content[@]}"; do
    if grep -q "$content" "$filename"; then
      match=$((match + 1))
    fi
  done

  if [ "$match" -eq "${#expected_content[@]}" ]; then
    DiagnosisResult="$filename의 내용이 정확합니다."
    Status="양호"
    append_to_csv "$DiagnosisResult" "$Status"
  else
    DiagnosisResult="$filename의 내용이 잘못되었습니다."
    Status="취약"
    append_to_csv "$DiagnosisResult" "$Status"
  fi
fi

cat $TMP1

echo "CSV report generated: $CSV_FILE"
echo ; echo
