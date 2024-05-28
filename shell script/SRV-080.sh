#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="$(basename "$0" .sh).csv"
if [ ! -f $CSV_FILE ]; then
    echo "Category,Code,Risk Level,Diagnosis Item,DiagnosisResult,Status" > $CSV_FILE
fi

BAR

CATEGORY="시스템 보안"
CODE="SRV-080"
RISK_LEVEL="중"
DIAGNOSIS_ITEM="프린터 드라이버 설치 제한 검사"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 일반 사용자에 의한 프린터 드라이버 설치가 제한된 경우
[취약]: 일반 사용자에 의한 프린터 드라이버 설치에 제한이 없는 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,$result,$status" >> $CSV_FILE
}

# CUPS 설정 파일 경로
CUPS_CONFIG_FILE="/etc/cups/cupsd.conf"

# 설정 파일에서 'SystemGroup' 설정 확인
if [ -f "$CUPS_CONFIG_FILE" ]; then
    system_group=$(grep -E "^SystemGroup" "$CUPS_CONFIG_FILE")

    if [ -n "$system_group" ]; then
        append_to_csv "CUPS 설정에서 시스템 그룹이 지정됨: $system_group" "양호"
    else
        append_to_csv "CUPS 설정에서 시스템 그룹이 지정되지 않음" "취약"
    fi
else
    append_to_csv "CUPS 설정 파일($CUPS_CONFIG_FILE)이 존재하지 않습니다." "취약"
fi

cat $TMP1

echo "CSV report generated: $CSV_FILE"
echo ; echo
cat $CSV_FILE
