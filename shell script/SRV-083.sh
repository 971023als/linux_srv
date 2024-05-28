#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
CATEGORY="시스템 시작"
CODE="SRV-083"
RISK_LEVEL="중"
DIAGNOSIS_ITEM="시스템 시작 스크립트 권한 설정"
SERVICE="System Startup"
DIAGNOSIS_RESULT=""
STATUS=""

BAR

cat << EOF >> $TMP1
[양호]: 시스템 스타트업 스크립트의 권한이 적절히 설정된 경우
[취약]: 시스템 스타트업 스크립트의 권한이 적절히 설정되지 않은 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,$SERVICE,$result,$status" >> $OUTPUT_CSV
}

TMP1=$(basename "$0").log
> $TMP1

# 시스템 스타트업 스크립트 디렉터리 목록
STARTUP_DIRS=("/etc/init.d" "/etc/rc.d" "/etc/systemd" "/usr/lib/systemd")

# 각 스타트업 스크립트의 권한 확인
for dir in "${STARTUP_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    scripts=$(find "$dir" -type f -name "*.sh" -o -name "*.service")
    for script in $scripts; do
      permissions=$(stat -c "%a" "$script")
      if [ "$permissions" -le "755" ]; then
        DIAGNOSIS_RESULT="$script 스크립트의 권한이 적절합니다. (권한: $permissions)"
        STATUS="양호"
      else
        DIAGNOSIS_RESULT="$script 스크립트의 권한이 적절하지 않습니다. (권한: $permissions)"
        STATUS="취약"
      fi
      append_to_csv "$DIAGNOSIS_RESULT" "$STATUS"
    done
  else
    DIAGNOSIS_RESULT="$dir 디렉터리가 존재하지 않습니다."
    STATUS="정보"
    append_to_csv "$DIAGNOSIS_RESULT" "$STATUS"
  fi
done

cat $TMP1

echo "CSV report generated: $OUTPUT_CSV"
echo ; echo

cat $OUTPUT_CSV
