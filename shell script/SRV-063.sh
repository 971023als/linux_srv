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
code="SRV-063"
riskLevel="중"
diagnosisItem="DNS 재귀 쿼리 설정 미흡"
diagnosisResult=""
status=""

# Define a temporary log file
TMP1=$(basename "$0").log
> $TMP1

# Print bar (assuming BAR is a defined function)
BAR

# Print code and description
echo "[SRV-063] DNS 재귀 쿼리 설정 미흡" >> $TMP1

# Append evaluation criteria to the log file
cat << EOF >> $TMP1
[양호]: DNS 서버에서 재귀적 쿼리가 제한적으로 설정된 경우
[취약]: DNS 서버에서 재귀적 쿼리가 적절하게 제한되지 않은 경우
EOF

BAR

# DNS 설정 파일 경로
DNS_CONFIG_FILE="/etc/bind/named.conf.options" # BIND 예시, 실제 파일 경로는 다를 수 있음

# 재귀 쿼리 설정 확인
if grep -qE "allow-recursion" "$DNS_CONFIG_FILE"; then
    recursion_setting=$(grep "allow-recursion" "$DNS_CONFIG_FILE")
    if echo "$recursion_setting" | grep -q "{ localhost; };" || echo "$recursion_setting" | grep -q "{ localnets; }"; then
        diagnosisResult="DNS 서버에서 재귀적 쿼리가 안전하게 제한됨: $recursion_setting"
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="DNS 서버에서 재귀적 쿼리 제한이 미흡함: $recursion_setting"
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    fi
else
    diagnosisResult="DNS 서버에서 재귀적 쿼리가 기본적으로 제한됨"
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
fi

# Write the final result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV

exit 0
