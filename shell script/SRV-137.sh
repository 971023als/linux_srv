#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="output.csv"
if [ ! -f $CSV_FILE ]; then
    echo "Category,Code,Risk Level,Diagnosis Item,DiagnosisResult,Status" > $CSV_FILE
fi

BAR

CATEGORY="네트워크 보안"
CODE="SRV-137"
RISK_LEVEL="높음"
DIAGNOSIS_ITEM="네트워크 서비스의 접근 제한 설정 미흡"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 네트워크 서비스의 접근 제한이 적절히 설정된 경우
[취약]: 네트워크 서비스의 접근 제한이 설정되지 않은 경우
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

# 네트워크 서비스 접근 제한 설정 확인
diagnosis_result=""
status="양호"

if [ -f /etc/hosts.deny ]; then
    etc_hostsdeny_allall_count=$(grep -vE '^#|^\s#' /etc/hosts.deny | awk '{gsub(" ", "", $0); print}' | grep -i 'all:all' | wc -l)
    if [ $etc_hostsdeny_allall_count -gt 0 ]; then
        if [ -f /etc/hosts.allow ]; then
            etc_hostsallow_allall_count=$(grep -vE '^#|^\s#' /etc/hosts.allow | awk '{gsub(" ", "", $0); print}' | grep -i 'all:all' | wc -l)
            if [ $etc_hostsallow_allall_count -gt 0 ]; then
                WARN "/etc/hosts.allow 파일에 'ALL : ALL' 설정이 있습니다." >> $TMP1
                diagnosis_result="/etc/hosts.allow 파일에 'ALL : ALL' 설정이 있습니다."
                status="취약"
            else
                OK "※ U-18 결과 : 양호(Good)" >> $TMP1
                diagnosis_result="적절히 설정되어 있습니다."
            fi
        else
            OK "※ U-18 결과 : 양호(Good)" >> $TMP1
            diagnosis_result="적절히 설정되어 있습니다."
        fi
    else
        WARN "/etc/hosts.deny 파일에 'ALL : ALL' 설정이 없습니다." >> $TMP1
        diagnosis_result="/etc/hosts.deny 파일에 'ALL : ALL' 설정이 없습니다."
        status="취약"
    fi
else
    WARN "/etc/hosts.deny 파일이 없습니다." >> $TMP1
    diagnosis_result="/etc/hosts.deny 파일이 없습니다."
    status="취약"
fi

# Append final result to CSV
append_to_csv "$CATEGORY" "$CODE" "$RISK_LEVEL" "$DIAGNOSIS_ITEM" "$diagnosis_result" "$status"

cat $TMP1

echo "CSV report generated: $CSV_FILE"
echo ; echo
ㄴ