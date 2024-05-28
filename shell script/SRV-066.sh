#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="네트워크 보안"
code="SRV-066"
riskLevel="중"
diagnosisItem="DNS Zone 전송 설정 검사"
diagnosisResult=""
status=""

# Define a temporary log file
TMP1=$(basename "$0").log
> $TMP1

# Print bar (assuming BAR is a defined function)
BAR

# Print code and description
echo "[SRV-066] DNS Zone 전송 설정 검사" >> $TMP1

# Append evaluation criteria to the log file
cat << EOF >> $TMP1
[양호]: DNS Zone Transfer가 안전하게 제한되어 있는 경우
[취약]: DNS Zone Transfer가 적절하게 제한되지 않은 경우
EOF

BAR

# Check if named service is running
ps_dns_count=$(ps -ef | grep -i 'named' | grep -v 'grep' | wc -l)
if [ $ps_dns_count -gt 0 ]; then
    if [ -f /etc/named.conf ]; then
        etc_namedconf_allowtransfer_count=$(grep -vE '^#|^\s#' /etc/named.conf | grep -i 'allow-transfer' | grep -i 'any' | wc -l)
        if [ $etc_namedconf_allowtransfer_count -gt 0 ]; then
            diagnosisResult="/etc/named.conf 파일에 allow-transfer { any; } 설정이 있습니다."
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
            echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
            cat $TMP1
            echo ; echo
            exit 0
        fi
    fi
fi

diagnosisResult="DNS Zone Transfer가 안전하게 제한되어 있습니다."
status="양호"
echo "OK: $diagnosisResult" >> $TMP1

# Write the final result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV

exit 0
