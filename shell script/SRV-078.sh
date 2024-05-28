#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="$(basename "$0" .sh).csv"
if [ ! -f $CSV_FILE ]; then
    echo "Category,Code,Risk Level,Diagnosis Item,Diagnosis Result,Status" > $CSV_FILE
fi

BAR

CATEGORY="계정 보안"
CODE="SRV-078"
RISK_LEVEL="낮"
DIAGNOSIS_ITEM="게스트 계정 활성화 상태 검사"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 불필요한 Guest 계정이 비활성화 되어 있는 경우
[취약]: 불필요한 Guest 계정이 활성화 되어 있는 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,$result,$status" >> $CSV_FILE
}

# Check for unnecessary guest accounts in /etc/passwd
if [ -f /etc/passwd ]; then
    if [ $(awk -F : '{print $1}' /etc/passwd | grep -wE 'guest|gues' | wc -l) -gt 0 ]; then
        append_to_csv "불필요한 Guest 계정이 활성화 되어 있습니다." "취약"
    else
        append_to_csv "불필요한 Guest 계정이 비활성화 되어 있습니다." "양호"
    fi
else
    append_to_csv "/etc/passwd 파일이 없습니다." "취약"
fi

# Check for unnecessary accounts in the root group
if [ -f /etc/group ]; then
    if [ $(awk -F : '$1=="root" {gsub(" ", "", $0); print $4}' /etc/group | awk '{gsub(",","\n",$0); print}' | grep -wE 'guest|gues' | wc -l) -gt 0 ]; then
        append_to_csv "관리자 그룹(root)에 불필요한 Guest 계정이 등록되어 있습니다." "취약"
    else
        append_to_csv "관리자 그룹(root)에 불필요한 Guest 계정이 없습니다." "양호"
    fi
else
    append_to_csv "/etc/group 파일이 없습니다." "취약"
fi

cat $TMP1

echo "CSV report generated: $CSV_FILE"
echo ; echo
cat $CSV_FILE
