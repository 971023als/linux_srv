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
code="SRV-046"
riskLevel="상"
diagnosisItem="웹 서비스 경로 설정 미흡"
diagnosisResult=""
status=""

# Define a temporary log file
TMP1=$(basename "$0").log
> $TMP1

# Print bar (assuming BAR is a defined function)
BAR

# Print code and description
echo "[SRV-046] 웹 서비스 경로 설정 미흡" >> $TMP1

# Append evaluation criteria to the log file
cat << EOF >> $TMP1
[양호]: 웹 서비스의 경로 설정이 안전하게 구성된 경우
[취약]: 웹 서비스의 경로 설정이 취약하게 구성된 경우
EOF

BAR

# Define configuration files for Apache and Nginx
APACHE_CONFIG_FILE="/etc/apache2/apache2.conf"
NGINX_CONFIG_FILE="/etc/nginx/nginx.conf"

# Check Apache configuration
if [ -f "$APACHE_CONFIG_FILE" ]; then
    if grep -qE "^[ \t]*<Directory" "$APACHE_CONFIG_FILE" && grep -qE "Options -Indexes" "$APACHE_CONFIG_FILE"; then
        diagnosisResult="Apache 설정에서 적절한 경로 설정이 확인됨: $APACHE_CONFIG_FILE"
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="Apache 설정에서 취약한 경로 설정이 확인됨: $APACHE_CONFIG_FILE"
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    fi
    echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
else
    diagnosisResult="Apache 설정 파일이 존재하지 않습니다: $APACHE_CONFIG_FILE"
    status="정보 없음"
    echo "INFO: $diagnosisResult" >> $TMP1
    echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

# Check Nginx configuration
if [ -f "$NGINX_CONFIG_FILE" ]; then
    if grep -qE "^[ \t]*location" "$NGINX_CONFIG_FILE"; then
        diagnosisResult="Nginx 설정에서 적절한 경로 설정이 확인됨: $NGINX_CONFIG_FILE"
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="Nginx 설정에서 취약한 경로 설정이 확인됨: $NGINX_CONFIG_FILE"
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    fi
    echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
else
    diagnosisResult="Nginx 설정 파일이 존재하지 않습니다: $NGINX_CONFIG_FILE"
    status="정보 없음"
    echo "INFO: $diagnosisResult" >> $TMP1
    echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

# Display the results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV

exit 0
