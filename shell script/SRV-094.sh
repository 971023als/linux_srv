#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $CSV_FILE ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $CSV_FILE
fi

BAR

CATEGORY="시스템 로깅"
CODE="SRV-094"
RISK_LEVEL="높음"
DIAGNOSIS_ITEM="crontab 참조 파일의 권한 설정 미흡"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 로그 기록 정책이 정책에 따라 설정되어 수립되어 있는 경우
[취약]: 로그 기록 정책이 정책에 따라 설정되어 수립되어 있지 않은 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,$result,$status" >> $CSV_FILE
}

# /etc/rsyslog.conf 파일의 존재 여부 및 내용을 확인합니다
filename="/etc/rsyslog.conf"
if [ ! -e "$filename" ]; then
    DiagnosisResult="$filename 가 존재하지 않습니다"
    Status="취약"
    append_to_csv "$DiagnosisResult" "$Status"
    echo "WARN: $DiagnosisResult" >> $TMP1
else
    # 필요한 로그 설정 내용을 배열로 정의합니다
    expected_content=(
        "*.info;mail.none;authpriv.none;cron.none /var/log/messages"
        "authpriv.* /var/log/secure"
        "mail.* /var/log/maillog"
        "cron.* /var/log/cron"
        "*.alert /dev/console"
        "*.emerg *"
    )

    # 파일 내에서 각 설정이 존재하는지 확인합니다
    match=0
    for content in "${expected_content[@]}"; do
        if grep -q "$content" "$filename"; then
            match=$((match + 1))
        fi
    done

    # 모든 필요한 설정이 존재하는지 결과를 출력합니다
    if [ "$match" -eq "${#expected_content[@]}" ]; then
        DiagnosisResult="$filename의 내용이 정확합니다."
        Status="양호"
        append_to_csv "$DiagnosisResult" "$Status"
        echo "OK: $DiagnosisResult" >> $TMP1
    else
        DiagnosisResult="$filename의 내용에 일부 설정이 누락되었습니다."
        Status="취약"
        append_to_csv "$DiagnosisResult" "$Status"
        echo "WARN: $DiagnosisResult" >> $TMP1
    fi
fi

cat $TMP1

echo ; echo

cat $CSV_FILE

echo "CSV report generated: $CSV_FILE"
echo ; echo
