#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="보안 관리"
code="SRV-012"
riskLevel="높음"
diagnosisItem=".netrc 파일 존재 및 권한 검사"
diagnosisResult=""
status=""

BAR

CODE="SRV-012"
diagnosisItem=".netrc 파일 내 중요 정보 노출"

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

# 결과 파일 초기화
TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 시스템 전체에서 .netrc 파일이 존재하지 않는 경우
[취약]: 시스템 전체에서 .netrc 파일이 존재하는 경우
EOF

BAR

# 시스템 전체에서 .netrc 파일 찾기
netrc_files=$(find / -name ".netrc" 2>/dev/null)

if [ -z "$netrc_files" ]; then
    diagnosisResult="시스템에 .netrc 파일이 존재하지 않습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
else
    diagnosisResult="다음 위치에 .netrc 파일이 존재합니다: $netrc_files"
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
    # .netrc 파일의 권한 확인 및 출력
    for file in $netrc_files; do
        permissions=$(ls -l $file)
        echo "권한 확인: $permissions" >> $TMP1
    done
fi

# Write the result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

BAR

cat $TMP1
echo ; echo

cat $OUTPUT_CSV
