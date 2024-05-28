#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="네트워크 보안"
code="SRV-029"
riskLevel="중"
diagnosisItem="SMB 세션 중단 시간 설정 검사"
diagnosisResult=""
status=""

BAR

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: SMB 서비스의 세션 중단 시간이 적절하게 설정된 경우
[취약]: SMB 서비스의 세션 중단 시간 설정이 미비한 경우
EOF

BAR

# SMB 설정 파일을 확인합니다.
SMB_CONF_FILE="/etc/samba/smb.conf"

# SMB 세션 중단 시간 설정을 확인합니다.
# 여기서는 'deadtime' 설정을 예로 듭니다.
if grep -q "^deadtime" "$SMB_CONF_FILE"; then
    deadtime=$(grep "^deadtime" "$SMB_CONF_FILE" | awk '{print $NF}')
    if [ "$deadtime" -gt 0 ]; then
        diagnosisResult="SMB 세션 중단 시간(deadtime)이 적절하게 설정되어 있습니다: $deadtime 분"
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="SMB 세션 중단 시간(deadtime) 설정이 미비합니다."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    fi
else
    diagnosisResult="SMB 세션 중단 시간(deadtime) 설정이 '$SMB_CONF_FILE' 파일에 존재하지 않습니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
fi

# Write the final result to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

BAR

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
