#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="웹 보안"
code="SRV-055"
riskLevel="상"
diagnosisItem="웹 서비스 설정 파일 노출"
diagnosisResult=""
status=""

BAR

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 웹 서비스 설정 파일이 외부에서 접근 불가능한 경우
[취약]: 웹 서비스 설정 파일이 외부에서 접근 가능한 경우
EOF

BAR

# 웹 서비스 설정 파일의 예시 경로
APACHE_CONFIG="/etc/apache2/apache2.conf"
NGINX_CONFIG="/etc/nginx/nginx.conf"

# Function to check file permissions
check_permissions() {
  local file=$1
  local service=$2

  if [ -f "$file" ]; then
    if ls -l "$file" | grep -qE "^-rw-------"; then
      diagnosisResult="$service 설정 파일($file)이 외부 접근으로부터 보호됩니다."
      status="양호"
      OK "$diagnosisResult" >> $TMP1
    else
      diagnosisResult="$service 설정 파일($file)의 접근 권한이 취약합니다."
      status="취약"
      WARN "$diagnosisResult" >> $TMP1
    fi
  else
    diagnosisResult="$service 설정 파일($file)이 존재하지 않습니다."
    status="정보"
    INFO "$diagnosisResult" >> $TMP1
  fi
  echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Check Apache config file permissions
check_permissions "$APACHE_CONFIG" "Apache"

# Check Nginx config file permissions
check_permissions "$NGINX_CONFIG" "Nginx"

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
