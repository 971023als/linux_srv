#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="output.csv"
if [ ! -f $CSV_FILE ]; then
    echo "Category,Code,Risk Level,Diagnosis Item,DiagnosisResult,Status" > $CSV_FILE
fi

BAR

CATEGORY="시스템 보안"
CODE="SRV-136"
RISK_LEVEL="높음"
DIAGNOSIS_ITEM="시스템 종료 권한 설정 검사"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 시스템 종료 권한이 적절히 제한된 경우
[취약]: 시스템 종료 권한이 제한되지 않은 경우
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

# 시스템 종료 권한 관련 설정 확인
shutdown_command="/sbin/shutdown"
diagnosis_result=""
status="양호"

if [ ! -x "$shutdown_command" ]; then
  WARN "shutdown 명령이 실행 가능하지 않습니다." >> $TMP1
  diagnosis_result="shutdown 명령이 실행 가능하지 않습니다."
  status="취약"
else
  OK "shutdown 명령이 실행 가능합니다." >> $TMP1
  diagnosis_result="shutdown 명령이 실행 가능합니다."
fi

# shutdown 명령에 대한 권한 확인
permissions=$(stat -c %A "$shutdown_command")
if [[ "$permissions" != *x* ]]; then
  WARN "shutdown 명령에 실행 권한이 없습니다." >> $TMP1
  diagnosis_result="shutdown 명령에 실행 권한이 없습니다."
  status="취약"
else
  OK "shutdown 명령에 실행 권한이 있습니다." >> $TMP1
  diagnosis_result="shutdown 명령에 실행 권한이 있습니다."
fi

# Append final result to CSV
append_to_csv "$CATEGORY" "$CODE" "$RISK_LEVEL" "$DIAGNOSIS_ITEM" "$diagnosis_result" "$status"

cat $TMP1

echo "CSV report generated: $CSV_FILE"
echo ; echo
