#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="$(basename "$0" .sh).csv"
if [ ! -f $CSV_FILE ]; then
    echo "Category,Code,Risk Level,Diagnosis Item,DiagnosisResult,Status" > $CSV_FILE
fi

BAR

CATEGORY="시스템 권한"
CODE="SRV-079"
RISK_LEVEL="높음"
DIAGNOSIS_ITEM="익명 사용자 권한 검사"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 익명 사용자에게 부적절한 권한이 적용되지 않은 경우
[취약]: 익명 사용자에게 부적절한 권한이 적용된 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,$result,$status" >> $CSV_FILE
}

# Check for world writable files
if [ $(find / -type f -perm -2 2>/dev/null | wc -l) -gt 0 ]; then
    append_to_csv "world writable 설정이 되어있는 파일이 있습니다." "취약"
else
    append_to_csv "world writable 설정이 되어있는 파일이 없습니다." "양호"
fi

cat $TMP1

echo "CSV report generated: $CSV_FILE"
echo ; echo
cat $CSV_FILE
