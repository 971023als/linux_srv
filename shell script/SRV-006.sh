#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="시스템 관리"
code="SRV-006"
riskLevel="중"
diagnosisItem="SMTP 서비스 로그 수준 설정 검사"
diagnosisResult=""
status=""

BAR

diagnosisItem="SMTP 서비스 로그 수준 설정 미흡"

# Define the configuration file and the LogLevel setting
SENDMAIL_CONFIG="/etc/mail/sendmail.cf"
LOG_LEVEL_SETTING="O LogLevel"

# Check the LogLevel setting in the sendmail configuration
if [ -f "$SENDMAIL_CONFIG" ]; then
    LOG_LEVEL=$(grep "^$LOG_LEVEL_SETTING" $SENDMAIL_CONFIG | awk '{print $3}')
    if [ -n "$LOG_LEVEL" ] && [ "$LOG_LEVEL" -ge 9 ]; then
        diagnosisResult="SMTP 서비스의 로그 수준이 적절하게 설정됨 (현재 수준: $LOG_LEVEL)."
        status="양호"
    else
        diagnosisResult="SMTP 서비스의 로그 수준이 낮게 설정됨 (현재 수준: ${LOG_LEVEL:-'미설정'})."
        status="취약"
    fi
else
    diagnosisResult="sendmail 구성 파일($SENDMAIL_CONFIG)을 찾을 수 없습니다."
    status="정보 없음"
fi

# Write the result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

BAR

cat $OUTPUT_CSV
echo ; echo
