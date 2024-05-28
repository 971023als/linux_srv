#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="네트워크 보안"
code="SRV-031"
riskLevel="중"
diagnosisItem="계정 목록 및 네트워크 공유 이름 노출 검사"
diagnosisResult=""
status=""

BAR

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: SMB 서비스에서 계정 목록 및 네트워크 공유 이름이 노출되지 않는 경우
[취약]: SMB 서비스에서 계정 목록 및 네트워크 공유 이름이 노출되는 경우
EOF

BAR

# SMB 설정 파일을 확인합니다.
SMB_CONF_FILE="/etc/samba/smb.conf"

# 공유 목록 및 계정 정보 노출을 방지하는 설정을 확인합니다.
# 예: 'enum shares', 'enum users' 설정을 확인
if grep -qE "^\s*enum\s*shares\s*=\s*yes|^\s*enum\s*users\s*=\s*yes" "$SMB_CONF_FILE"; then
    diagnosisResult="SMB 서비스에서 계정 목록 또는 네트워크 공유 이름이 노출될 수 있습니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
else
    diagnosisResult="SMB 서비스에서 계정 목록 및 네트워크 공유 이름이 적절하게 보호되고 있습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
fi

# Write the final result to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

BAR

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
