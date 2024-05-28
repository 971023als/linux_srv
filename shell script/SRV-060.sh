#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="웹 보안"
code="SRV-060"
riskLevel="중"
diagnosisItem="기본 계정(아이디 또는 비밀번호) 미변경 검사"
service="Web Service"
diagnosisResult=""
status=""

BAR

CODE="SRV-060"
diagnosisItem="웹 서비스 기본 계정(아이디 또는 비밀번호) 미변경"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 웹 서비스의 기본 계정(아이디 또는 비밀번호)이 변경된 경우
[취약]: 웹 서비스의 기본 계정(아이디 또는 비밀번호)이 변경되지 않은 경우
EOF

BAR

# 웹 서비스의 기본 계정 설정 파일 예시 (실제 환경에 맞게 조정)
CONFIG_FILE="/etc/web_service/config"

# 기본 계정 설정 확인 (예시: 'admin' 또는 'password')
if grep -qE "username=admin|password=password" "$CONFIG_FILE"; then
    diagnosisResult="웹 서비스의 기본 계정(아이디 또는 비밀번호)이 변경되지 않았습니다: $CONFIG_FILE"
    status="취약"
    WARN "$diagnosisResult" >> $TMP1
else
    diagnosisResult="웹 서비스의 기본 계정(아이디 또는 비밀번호)이 변경되었습니다: $CONFIG_FILE"
    status="양호"
    OK "$diagnosisResult" >> $TMP1
fi

# Write the final result to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV