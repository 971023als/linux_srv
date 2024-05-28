#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="네트워크 보안"
code="SRV-015"
riskLevel="중"
diagnosisItem="불필요한 NFS 서비스 실행 상태 검사"
diagnosisResult=""
status=""

BAR

CODE="SRV-015"
diagnosisItem="불필요한 NFS 서비스 실행"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 불필요한 NFS 서비스 관련 데몬이 비활성화 되어 있는 경우
[취약]: 불필요한 NFS 서비스 관련 데몬이 활성화 되어 있는 경우
EOF

BAR

if [ $(ps -ef | grep -iE 'nfs|rpc.statd|statd|rpc.lockd|lockd' | grep -ivE 'grep|kblockd|rstatd' | wc -l) -gt 0 ]; then
    diagnosisResult="불필요한 NFS 서비스 관련 데몬이 실행 중입니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
else
    diagnosisResult="불필요한 NFS 서비스 관련 데몬이 비활성화 되어 있습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
fi

# Write the result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1
echo ; echo

cat $OUTPUT_CSV
