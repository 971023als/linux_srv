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
CODE="SRV-112"
RISK_LEVEL="중"
DIAGNOSIS_ITEM="Cron 서비스 로깅 미설정"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: Cron 서비스 로깅이 적절하게 설정되어 있는 경우
[취약]: Cron 서비스 로깅이 적절하게 설정되어 있지 않은 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,시스템 로깅,$result,$status" >> $CSV_FILE
}

# Check rsyslog.conf for Cron logging configuration
rsyslog_conf="/etc/rsyslog.conf"
if [ ! -f "$rsyslog_conf" ]; then
    append_to_csv "rsyslog.conf 파일이 존재하지 않습니다." "취약"
else
    if grep -q "cron.*" "$rsyslog_conf"; then
        append_to_csv "Cron 로깅이 rsyslog.conf에서 설정되었습니다." "양호"
    else
        append_to_csv "Cron 로깅이 rsyslog.conf에서 설정되지 않았습니다." "취약"
    fi
fi

# Check for the existence of the Cron log file
cron_log="/var/log/cron"
if [ ! -f "$cron_log" ]; then
    append_to_csv "Cron 로그 파일이 존재하지 않습니다." "취약"
else
    append_to_csv "Cron 로그 파일이 존재합니다." "양호"
fi

cat $TMP1

echo "CSV report generated: $CSV_FILE"
echo ; echo
