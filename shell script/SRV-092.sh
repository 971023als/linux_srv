#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $CSV_FILE ]; then
    echo "Category,Code,Risk Level,Diagnosis Item,DiagnosisResult,Status" > $CSV_FILE
fi

BAR

CATEGORY="사용자 환경 설정"
CODE="SRV-092"
RISK_LEVEL="중"
DIAGNOSIS_ITEM="사용자 홈 디렉토리 설정 미흡"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 모든 사용자의 홈 디렉터리가 적절히 설정되어 있는 경우
[취약]: 하나 이상의 사용자의 홈 디렉터리가 적절히 설정되지 않은 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,$result,$status" >> $CSV_FILE
}

# /etc/passwd에서 사용자 홈 디렉터리 정보 추출 및 확인
while IFS=: read -r user _ _ _ _ home_dir _; do
    if [ ! -d "$home_dir" ] || [ -z "$home_dir" ]; then
        DiagnosisResult="사용자 $user 에 대한 홈 디렉터리($home_dir)가 잘못 설정되었습니다."
        Status="취약"
        append_to_csv "$DiagnosisResult" "$Status"
        echo "WARN: $DiagnosisResult" >> $TMP1
    else
        DiagnosisResult="사용자 $user 의 홈 디렉터리($home_dir)가 적절히 설정되었습니다."
        Status="양호"
        append_to_csv "$DiagnosisResult" "$Status"
        echo "OK: $DiagnosisResult" >> $TMP1
    fi
done < /etc/passwd

cat $TMP1

echo ; echo

cat $CSV_FILE

echo "CSV report generated: $CSV_FILE"
echo ; echo
