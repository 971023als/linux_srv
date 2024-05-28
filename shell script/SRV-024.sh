#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="네트워크 보안"
code="SRV-024"
riskLevel="높음"
diagnosisItem="Telnet 인증 방식 검사"
diagnosisResult=""
status=""

BAR

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: Telnet 서비스가 비활성화되어 있거나 보안 인증 방식을 사용하는 경우
[취약]: Telnet 서비스가 활성화되어 있고 보안 인증 방식을 사용하지 않는 경우
EOF

BAR

# Telnet 서비스 상태를 확인합니다.
if systemctl is-active --quiet telnet.socket; then
    # Telnet 서비스가 활성화된 경우, 추가적인 설정 확인이 필요할 수 있음
    # Linux 시스템에서 NTLM 인증 설정을 직접 확인하는 방법은 제한적임
    # 해당 확인은 Windows 환경에 더 적합함
    diagnosisResult="Telnet 서비스가 활성화되어 있습니다. 추가 보안 설정 확인이 필요할 수 있습니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
else
    diagnosisResult="Telnet 서비스가 비활성화되어 있습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
fi

# Write the final result to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

BAR

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
