#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="$(basename "$0" .sh).csv"
if [ ! -f $CSV_FILE ]; then
    echo "Category,Code,Risk Level,Diagnosis Item,DiagnosisResult,Status" > $CSV_FILE
fi

BAR

CATEGORY="네트워크 보안"
CODE="SRV-074"
RISK_LEVEL="중"
DIAGNOSIS_ITEM="불필요하거나 관리되지 않는 계정 검사"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 불필요하거나 관리되지 않는 계정이 존재하지 않는 경우
[취약]: 불필요하거나 관리되지 않는 계정이 존재하는 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,$result,$status" >> $CSV_FILE
}

if [ -f /etc/passwd ]; then
    # Check for unnecessary accounts
    if [ $(awk -F : '{print $1}' /etc/passwd | grep -wE 'daemon|bin|sys|adm|listen|nobody|nobody4|noaccess|diag|operator|gopher|games|ftp|apache|httpd|www-data|mysql|mariadb|postgres|mail|postfix|news|lp|uucp|nuucp' | wc -l) -gt 0 ]; then
        append_to_csv "불필요한 계정이 존재합니다." "취약"
    else
        append_to_csv "불필요한 계정이 존재하지 않습니다." "양호"
    fi
fi

if [ -f /etc/group ]; then
    # Check for unnecessary accounts in the root group
    if [ $(awk -F : '$1=="root" {gsub(" ", "", $0); print $4}' /etc/group | awk '{gsub(",","\n",$0); print}' | grep -wE 'daemon|bin|sys|adm|listen|nobody|nobody4|noaccess|diag|operator|gopher|games|ftp|apache|httpd|www-data|mysql|mariadb|postgres|mail|postfix|news|lp|uucp|nuucp' | wc -l) -gt 0 ]; then
        append_to_csv "관리자 그룹(root)에 불필요한 계정이 등록되어 있습니다." "취약"
    else
        append_to_csv "관리자 그룹(root)에 불필요한 계정이 없습니다." "양호"
    fi
fi

cat $TMP1

echo "CSV report generated: $CSV_FILE"
echo ; echo
cat $CSV_FILE
