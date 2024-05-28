#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="네트워크 보안"
code="SRV-011"
riskLevel="높음"
diagnosisItem="FTP 시스템 관리자 계정 접근 제한 설정 검사"
service="Account Management"
diagnosisResult=""
status=""

BAR

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

# 결과 파일 초기화
TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: FTP 서비스에서 시스템 관리자 계정의 접근이 제한되는 경우
[취약]: FTP 서비스에서 시스템 관리자 계정의 접근이 제한되지 않는 경우
EOF

BAR

# FTP 사용자 제한 설정 파일 경로
FTP_USERS_FILE="/etc/vsftpd/ftpusers"

# 'root' 계정의 FTP 접근 제한 여부 확인
if [ -f "$FTP_USERS_FILE" ]; then
    if grep -q "^root" "$FTP_USERS_FILE"; then
        diagnosisResult="FTP 서비스에서 root 계정의 접근이 제한됩니다."
        status="양호"
    else
        diagnosisResult="FTP 서비스에서 root 계정의 접근이 제한되지 않습니다."
        status="취약"
    fi
else
    diagnosisResult="FTP 사용자 제한 설정 파일($FTP_USERS_FILE)이 존재하지 않습니다."
    status="정보 없음"
fi

# Write the result to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

BAR

cat $TMP1
echo ; echo

cat $OUTPUT_CSV
