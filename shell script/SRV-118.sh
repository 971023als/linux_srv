#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $CSV_FILE ]; then
    echo "Category,Code,Risk Level,Diagnosis Item,DiagnosisResult,Status" > $CSV_FILE
fi

BAR

CATEGORY="시스템 유지 관리"
CODE="SRV-118"
RISK_LEVEL="고"
DIAGNOSIS_ITEM="주기적인 보안패치 및 벤더 권고사항 미적용"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 최신 보안패치 및 업데이트가 적용된 경우
[취약]: 최신 보안패치 및 업데이트가 적용되지 않은 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,$result,$status" >> $CSV_FILE
}

# Check system update status
update_status=$(apt-get -s upgrade | grep "upgraded,")
if [[ $update_status == *"0 upgraded"* ]]; then
  DiagnosisResult="모든 패키지가 최신 상태입니다."
  Status="양호"
else
  DiagnosisResult="일부 패키지가 업데이트되지 않았습니다: $update_status"
  Status="취약"
fi
append_to_csv "$DiagnosisResult" "$Status"

# Check for security policy application
if [ -e "/etc/security/policies.conf" ]; then
  policy_content=$(grep "important_security_policy" /etc/security/policies.conf)
  if [ -z "$policy_content" ]; then
    DiagnosisResult="중요 보안 정책이 /etc/security/policies.conf에 설정되지 않음"
    Status="취약"
  else
    DiagnosisResult="중요 보안 정책이 설정됨: $policy_content"
    Status="양호"
  fi
else
  DiagnosisResult="/etc/security/policies.conf 파일이 존재하지 않음"
  Status="취약"
fi
append_to_csv "$DiagnosisResult" "$Status"

cat $TMP1

echo ; echo

cat $CSV_FILE

echo "CSV report generated: $CSV_FILE"
echo ; echo
