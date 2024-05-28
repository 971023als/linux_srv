#!/bin/bash

# Load external functions from function.sh
. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="DNS 보안"
code="SRV-062"
riskLevel="중"
diagnosisItem="DNS 서비스 정보 노출"
diagnosisResult=""
status=""

# Define a temporary log file
TMP1=$(basename "$0").log
> $TMP1

# Print bar (assuming BAR is a defined function)
BAR

# Print code and description
echo "[SRV-062] DNS 서비스 정보 노출" >> $TMP1

# Append evaluation criteria to the log file
cat << EOF >> $TMP1
[양호]: DNS 서비스 정보가 안전하게 보호되고 있는 경우
[취약]: DNS 서비스 정보가 노출되고 있는 경우
EOF

BAR

# DNS 설정 파일 경로
DNS_CONFIG_FILE="/etc/bind/named.conf"  # BIND 사용 예시, 실제 환경에 따라 달라질 수 있음

# Check for version hiding option
if grep -qE "version \"none\"" "$DNS_CONFIG_FILE"; then
    diagnosisResult="DNS 서비스에서 버전 정보가 숨겨져 있습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
else
    diagnosisResult="DNS 서비스에서 버전 정보가 노출될 수 있습니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
fi

# Check for unnecessary zone transfer permissions
if grep -qE "allow-transfer" "$DNS_CONFIG_FILE"; then
    diagnosisResult="DNS 서비스에서 불필요한 Zone Transfer가 허용될 수 있습니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
else
    diagnosisResult="DNS 서비스에서 불필요한 Zone Transfer가 제한됩니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
fi

# Write the final result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV

exit 0
