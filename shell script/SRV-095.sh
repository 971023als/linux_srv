#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $CSV_FILE ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $CSV_FILE
fi

BAR

CATEGORY="파일 시스템 보안"
CODE="SRV-095"
RISK_LEVEL="높음"
DIAGNOSIS_ITEM="소유자 또는 그룹 권한이 없는 파일 또는 디렉터리 존재"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 시스템에 존재하지 않는 소유자나 그룹 권한을 가진 파일 또는 디렉터리가 없는 경우
[취약]: 시스템에 존재하지 않는 소유자나 그룹 권한을 가진 파일 또는 디렉터리가 있는 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,$result,$status" >> $CSV_FILE
}

# Check for files or directories with non-existent owners or groups
if [ $(find / \( -nouser -o -nogroup \) 2>/dev/null | wc -l) -gt 0 ]; then
    DiagnosisResult="소유자가 존재하지 않는 파일 및 디렉터리가 존재합니다."
    Status="취약"
    append_to_csv "$DiagnosisResult" "$Status"
    echo "WARN: $DiagnosisResult" >> $TMP1
else
    DiagnosisResult="시스템에 존재하지 않는 소유자나 그룹 권한을 가진 파일 또는 디렉터리가 없습니다."
    Status="양호"
    append_to_csv "$DiagnosisResult" "$Status"
    echo "OK: $DiagnosisResult" >> $TMP1
fi

# Check for non-existent device files in /dev directory
if [ $(find /dev -type f -name '[0-9]*' 2>/dev/null | wc -l) -gt 0 ]; then
    DiagnosisResult="/dev 디렉터리에 존재하지 않는 device 파일이 존재합니다."
    Status="취약"
    append_to_csv "$DiagnosisResult" "$Status"
    echo "WARN: $DiagnosisResult" >> $TMP1
else
    DiagnosisResult="시스템에 존재하지 않는 device 파일이 없습니다."
    Status="양호"
    append_to_csv "$DiagnosisResult" "$Status"
    echo "OK: $DiagnosisResult" >> $TMP1
fi

# Check for accounts with null home directories
homedirectory_null_count=$(awk -F : '$7!="/bin/false" && $7!="/sbin/nologin" && $6==""' /etc/passwd | wc -l)
if [ $homedirectory_null_count -gt 0 ]; then
    DiagnosisResult="홈 디렉터리가 존재하지 않는 계정이 있습니다."
    Status="취약"
    append_to_csv "$DiagnosisResult" "$Status"
    echo "WARN: $DiagnosisResult" >> $TMP1
else
    homedirectory_slash_count=$(awk -F : '$7!="/bin/false" && $7!="/sbin/nologin" && $1!="root" && $6=="/"' /etc/passwd | wc -l)
    if [ $homedirectory_slash_count -gt 0 ]; then
        DiagnosisResult="관리자 계정(root)이 아닌데 홈 디렉터리가 '/'로 설정된 계정이 있습니다."
        Status="취약"
        append_to_csv "$DiagnosisResult" "$Status"
        echo "WARN: $DiagnosisResult" >> $TMP1
    else
        DiagnosisResult="시스템에 존재하지 않는 홈 디렉터리가 없습니다."
        Status="양호"
        append_to_csv "$DiagnosisResult" "$Status"
        echo "OK: $DiagnosisResult" >> $TMP1
    fi
fi

cat $TMP1

echo ; echo

cat $CSV_FILE

echo "CSV report generated: $CSV_FILE"
echo ; echo
