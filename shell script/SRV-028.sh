#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="네트워크 보안"
code="SRV-028"
riskLevel="높음"
diagnosisItem="SSH 원격 터미널 타임아웃 설정 검사"
diagnosisResult=""
status=""

BAR

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: SSH 원격 터미널 접속 타임아웃이 적절하게 설정된 경우
[취약]: SSH 원격 터미널 접속 타임아웃이 설정되지 않은 경우
EOF

BAR

# SSH 설정 파일을 확인합니다.
SSH_CONFIG_FILE="/etc/ssh/sshd_config"

# Check for the presence of ClientAliveInterval and ClientAliveCountMax settings
if grep -q "^ClientAliveInterval" "$SSH_CONFIG_FILE" && grep -q "^ClientAliveCountMax" "$SSH_CONFIG_FILE"; then
    diagnosisResult="SSH 원격 터미널 타임아웃 설정이 적절하게 구성되어 있습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
else
    diagnosisResult="SSH 원격 터미널 타임아웃 설정이 미비합니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
fi

# Write the final result to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

BAR

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
