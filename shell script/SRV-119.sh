#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $CSV_FILE ]; then
    echo "Category,Code,Risk Level,Diagnosis Item,DiagnosisResult,Status" > $CSV_FILE
fi

BAR

CATEGORY="시스템 보안"
CODE="SRV-119"
RISK_LEVEL="중"
DIAGNOSIS_ITEM="백신 프로그램 업데이트 상태 검사"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 백신 프로그램이 최신 버전으로 업데이트 되어 있는 경우
[취약]: 백신 프로그램이 최신 버전으로 업데이트 되어 있지 않은 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,$result,$status" >> $CSV_FILE
}

# Check ClamAV update status
clamav_version=$(clamscan --version | grep -oP 'ClamAV \K[0-9.]+')
latest_clamav_version=$(curl -s https://www.clamav.net/downloads | grep -oP 'ClamAV \K[0-9.]+')

if [ "$clamav_version" == "$latest_clamav_version" ]; then
  DiagnosisResult="ClamAV가 최신 버전입니다: $clamav_version"
  Status="양호"
else
  DiagnosisResult="ClamAV가 최신 버전이 아닙니다. 현재 버전: $clamav_version, 최신 버전: $latest_clamav_version"
  Status="취약"
fi

append_to_csv "$DiagnosisResult" "$Status"

cat $TMP1

echo ; echo

cat $CSV_FILE

echo "CSV report generated: $CSV_FILE"
echo ; echo
