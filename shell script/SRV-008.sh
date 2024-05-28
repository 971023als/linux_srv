#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="시스템 관리"
code="SRV-008"
riskLevel="중"
diagnosisItem="SMTP 서비스 DoS 방지 기능 설정 검사"
service="Account Management"
diagnosisResult=""
status=""

BAR

CODE="SRV-008"
diagnosisItem="SMTP 서비스의 DoS 방지 기능 미설정"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: SMTP 서비스에 DoS 방지 설정이 적용된 경우
[취약]: SMTP 서비스에 DoS 방지 설정이 적용되지 않은 경우
EOF

BAR

echo "[SRV-008] SMTP 서비스의 DoS 방지 기능 미설정" >> $TMP1

# Sendmail 설정 점검
SENDMAIL_CF="/etc/mail/sendmail.cf"
SENDMAIL_SETTINGS=("MaxDaemonChildren" "ConnectionRateThrottle" "MinFreeBlocks" "MaxHeadersLength" "MaxMessageSize")

echo "Sendmail DoS 방지 설정을 점검 중입니다..." >> $TMP1
if [ -f "$SENDMAIL_CF" ]; then
    sendmail_status="양호"
    for setting in "${SENDMAIL_SETTINGS[@]}"; do
        if grep -E -q "^O\s*$setting=" "$SENDMAIL_CF"; then
            echo "OK: $setting 설정이 적용되었습니다." >> $TMP1
        else
            echo "WARN: $setting 설정이 적용되지 않았습니다." >> $TMP1
            sendmail_status="취약"
        fi
    done
    diagnosisResult=$(grep -E "^OK|WARN" $TMP1 | awk '{print $2, $3}' | tr '\n' ' ')
    status=$sendmail_status
else
    echo "INFO: Sendmail 설정 파일이 존재하지 않습니다." >> $TMP1
    diagnosisResult="Sendmail 설정 파일이 존재하지 않습니다."
    status="정보 없음"
fi

# Write the result to CSV for Sendmail
echo "$category,$CODE,$riskLevel,$diagnosisItem,Sendmail,$diagnosisResult,$status" >> $OUTPUT_CSV

# Reset diagnosisResult and status for Postfix
diagnosisResult=""
status=""

# Postfix 설정 점검
POSTFIX_MAIN_CF="/etc/postfix/main.cf"
POSTFIX_SETTINGS=("message_size_limit" "header_size_limit" "default_process_limit" "local_destination_concurrency_limit" "smtpd_recipient_limit")

echo "Postfix DoS 방지 설정을 점검 중입니다..." >> $TMP1
if [ -f "$POSTFIX_MAIN_CF" ]; then
    postfix_status="양호"
    for setting in "${POSTFIX_SETTINGS[@]}"; do
        if grep -q "^$setting" "$POSTFIX_MAIN_CF"; then
            echo "OK: $setting 설정이 적용되었습니다." >> $TMP1
        else
            echo "WARN: $setting 설정이 명시적으로 구성되지 않았습니다(기본값 사용 가능)." >> $TMP1
            postfix_status="취약"
        fi
    done
    diagnosisResult=$(grep -E "^OK|WARN" $TMP1 | awk '{print $2, $3}' | tr '\n' ' ')
    status=$postfix_status
else
    echo "INFO: Postfix 설정 파일이 존재하지 않습니다." >> $TMP1
    diagnosisResult="Postfix 설정 파일이 존재하지 않습니다."
    status="정보 없음"
fi

# Write the result to CSV for Postfix
echo "$category,$CODE,$riskLevel,$diagnosisItem,Postfix,$diagnosisResult,$status" >> $OUTPUT_CSV

BAR

cat $TMP1
echo ; echo

cat $OUTPUT_CSV
