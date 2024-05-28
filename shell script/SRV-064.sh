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
code="SRV-064"
riskLevel="중"
diagnosisItem="DNS 서버 버전 검사"
diagnosisResult=""
status=""

# Define a temporary log file
TMP1=$(basename "$0").log
> $TMP1

# Print bar (assuming BAR is a defined function)
BAR

# Print code and description
echo "[SRV-064] DNS 서버 버전 검사" >> $TMP1

# Append evaluation criteria to the log file
cat << EOF >> $TMP1
[양호]: DNS 서비스가 최신 버전으로 업데이트되어 있는 경우
[취약]: DNS 서비스가 최신 버전으로 업데이트되어 있지 않은 경우
EOF

BAR

# Check if named service is running
ps_dns_count=$(ps -ef | grep -i 'named' | grep -v 'grep' | wc -l)
if [ $ps_dns_count -gt 0 ]; then
    # Check BIND version
    bind_version=$(named -v 2>/dev/null | awk '{print $2}')
    if [[ $bind_version =~ ^9\.18\.[7-9]$|^9\.18\.[1-9][0-6]$ ]]; then
        diagnosisResult="BIND 버전이 최신 버전(9.18.7 이상)입니다."
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="BIND 버전이 최신 버전(9.18.7 이상)이 아닙니다: $bind_version"
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    fi
else
    diagnosisResult="DNS 서비스(named)가 실행되고 있지 않습니다."
    status="정보 없음"
    echo "INFO: $diagnosisResult" >> $TMP1
fi

# Write the final result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV

exit 0
