#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $CSV_FILE ]; then
    echo "Category,Code,Risk Level,Diagnosis Item,DiagnosisResult,Status" > $CSV_FILE
fi

BAR

CATEGORY="사용자 계정 보안"
CODE="SRV-123"
RISK_LEVEL="상"
DIAGNOSIS_ITEM="최종 로그인 사용자 계정 노출 검사"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 최종 로그인 사용자 정보가 노출되지 않는 경우
[취약]: 최종 로그인 사용자 정보가 노출되는 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,$result,$status" >> $CSV_FILE
}

# Check login message files
files=("/etc/motd" "/etc/issue" "/etc/issue.net")

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        if grep -q 'Last login' "$file"; then
            DiagnosisResult="파일 $file 에 최종 로그인 사용자 정보가 포함되어 있습니다."
            Status="취약"
        else
            DiagnosisResult="파일 $file 에 최종 로그인 사용자 정보가 포함되지 않았습니다."
            Status="양호"
        fi
    else
        DiagnosisResult="파일 $file 이(가) 존재하지 않습니다."
        Status="정보"
    fi
    append_to_csv "$DiagnosisResult" "$Status"
done

cat $TMP1

echo ; echo

cat $CSV_FILE

echo "CSV report generated: $CSV_FILE"
echo ; echo
