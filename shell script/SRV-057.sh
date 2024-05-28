#!/bin/bash

# Load external functions from function.sh
. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="웹 보안"
code="SRV-057"
riskLevel="중"
diagnosisItem="웹 서비스 경로 내 파일의 접근 통제 미흡"
diagnosisResult=""
status=""

# Define a temporary log file
TMP1=$(basename "$0").log
> $TMP1

# Print bar (assuming BAR is a defined function)
BAR

# Print code and description
echo "[SRV-057] 웹 서비스 경로 내 파일의 접근 통제 미흡" >> $TMP1

# Append evaluation criteria to the log file
cat << EOF >> $TMP1
[양호]: 웹 서비스 경로 내 파일의 접근 권한이 적절하게 설정된 경우
[취약]: 웹 서비스 경로 내 파일의 접근 권한이 적절하게 설정되지 않은 경우
EOF

BAR

# 웹 서비스 경로 설정
WEB_SERVICE_PATH="/var/www/html" # 실제 경로에 맞게 조정하세요.

# 웹 서비스 경로 내 파일 접근 권한 확인
# 예: 파일 권한이 755 이상으로 설정되어 있는지 확인
incorrect_permissions=$(find "$WEB_SERVICE_PATH" -type f ! -perm 755)

if [ -n "$incorrect_permissions" ]; then
    diagnosisResult="웹 서비스 경로 내에 부적절한 파일 권한이 있습니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
else
    diagnosisResult="웹 서비스 경로 내의 모든 파일의 권한이 적절하게 설정되어 있습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
fi

# Write the final result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV

exit 0
