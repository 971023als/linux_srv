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
code="SRV-059"
riskLevel="상"
diagnosisItem="웹 서비스 서버 명령 실행 기능 제한 설정 미흡"
diagnosisResult=""
status=""

# Define a temporary log file
TMP1=$(basename "$0").log
> $TMP1

# Print bar (assuming BAR is a defined function)
BAR

# Print code and description
echo "[SRV-059] 웹 서비스 서버 명령 실행 기능 제한 설정 미흡" >> $TMP1

# Append evaluation criteria to the log file
cat << EOF >> $TMP1
[양호]: 웹 서비스에서 서버 명령 실행 기능이 적절하게 제한된 경우
[취약]: 웹 서비스에서 서버 명령 실행 기능의 제한이 미흡한 경우
EOF

BAR

# Function to check server command execution restrictions
check_command_execution() {
  local file=$1
  local service=$2
  local pattern=$3
  local result_message

  if [ -f "$file" ]; then
    if grep -qE "$pattern" "$file"; then
      result_message="$service에서 서버 명령 실행이 허용될 수 있습니다: $file"
      status="취약"
      echo "WARN: $result_message" >> $TMP1
    else
      result_message="$service에서 서버 명령 실행 기능이 적절하게 제한됩니다: $file"
      status="양호"
      echo "OK: $result_message" >> $TMP1
    fi
  else
    result_message="$service 설정 파일이 존재하지 않습니다: $file"
    status="정보 없음"
    echo "INFO: $result_message" >> $TMP1
  fi
  diagnosisResult=$result_message
  echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Apache 또는 Nginx 웹 서비스의 서버 명령 실행 제한 설정 확인
APACHE_CONFIG_FILE="/etc/apache2/apache2.conf"
NGINX_CONFIG_FILE="/etc/nginx/nginx.conf"

# Apache에서 서버 명령 실행 제한 확인
check_command_execution "$APACHE_CONFIG_FILE" "Apache" "^[ \t]*ScriptAlias"

# Nginx에서 FastCGI 스크립트 실행 제한 확인
check_command_execution "$NGINX_CONFIG_FILE" "Nginx" "fastcgi_pass"

cat $TMP1

echo ; echo

cat $OUTPUT_CSV

exit 0
