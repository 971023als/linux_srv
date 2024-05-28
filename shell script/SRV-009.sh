#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="시스템 관리"
code="SRV-009"
riskLevel="중"
diagnosisItem="SMTP 스팸 메일 릴레이 제한 설정 검사"
diagnosisResult=""
status=""

BAR 

CODE="SRV-009"
diagnosisItem="SMTP 서비스 스팸 메일 릴레이 제한 미설정"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR 

cat << EOF >> $TMP1
[양호]: SMTP 서비스를 사용하지 않거나 릴레이 제한이 설정되어 있는 경우
[취약]: SMTP 서비스를 사용하거나 릴레이 제한이 설정이 없는 경우
EOF

BAR

echo "[SRV-009] SMTP 서비스 스팸 메일 릴레이 제한 미설정" >> $TMP1

# Check if SMTP port is open
smtp_port_count=$(netstat -nat 2>/dev/null | grep -w ':25' | grep -Ei 'listen|established|syn_sent|syn_received' | wc -l)

if [ $smtp_port_count -gt 0 ]; then
    # Check Sendmail configuration
    sendmailcf_exists_count=$(find / -name 'sendmail.cf' -type f 2>/dev/null | wc -l)
    if [ $sendmailcf_exists_count -gt 0 ]; then
        sendmailcf_files=($(find / -name 'sendmail.cf' -type f 2>/dev/null))
        for ((i=0; i<${#sendmailcf_files[@]}; i++)); do
            sendmailcf_relaying_denied_count=$(grep -vE '^#|^\s#' ${sendmailcf_files[$i]} | grep -i 'R$\*' | grep -i 'Relaying denied' | wc -l)
            if [ $sendmailcf_relaying_denied_count -eq 0 ]; then
                diagnosisResult="${sendmailcf_files[$i]} 파일에 릴레이 제한이 설정되어 있지 않습니다."
                status="취약"
                echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
                cat $TMP1
                echo ; echo
                exit 0
            fi
        done
    fi

    # Check Postfix configuration
    postfix_main_cf="/etc/postfix/main.cf"
    if [ -f "$postfix_main_cf" ]; then
        relay_domains=$(grep -vE '^#|^\s#' $postfix_main_cf | grep -i 'relay_domains')
        smtpd_recipient_restrictions=$(grep -vE '^#|^\s#' $postfix_main_cf | grep -i 'smtpd_recipient_restrictions')
        if [ -z "$relay_domains" ] || [ -z "$smtpd_recipient_restrictions" ]; then
            diagnosisResult="$postfix_main_cf 파일에 릴레이 제한이 설정되어 있지 않습니다."
            status="취약"
            echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
            cat $TMP1
            echo ; echo
            exit 0
        fi
    fi
else
    diagnosisResult="SMTP 서비스가 실행 중이지 않거나 포트 25가 열려 있지 않습니다."
    status="양호"
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    cat $TMP1
    echo ; echo
    exit 0
fi

diagnosisResult="SMTP 서비스가 실행 중이지만 릴레이 제한이 설정되어 있습니다."
status="양호"
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1
echo ; echo

cat $OUTPUT_CSV
