#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE=$(basename "$0").csv
echo "Category,Code,Risk Level,Diagnosis Item,DiagnosisResult,Status" > $CSV_FILE

# Function to append results to CSV file
append_to_csv() {
  local category=$1
  local code=$2
  local risk_level=$3
  local diagnosis_item=$4
  local diagnosis_result=$5
  local status=$6
  echo "$category,$code,$risk_level,$diagnosis_item,$diagnosis_result,$status" >> $CSV_FILE
}

# Function to log results
log_result() {
  local type=$1
  local message=$2
  echo "$type $message" >> $TMP1
}

# Initialize log file
TMP1=$(basename "$0").log
> $TMP1

BAR

CODE="SRV-148"
diagnosisItem="웹 서비스 정보 노출"

cat << EOF >> $TMP1
[양호]: 웹 서버에서 버전 정보 및 운영체제 정보 노출이 제한된 경우
[취약]: 웹 서버에서 버전 정보 및 운영체제 정보가 노출되는 경우
EOF

BAR

# Set diagnostic variables
category="웹 서비스 보안"
code="SRV-148"
riskLevel="중"
diagnosisItem="웹 서비스 정보 노출"
diagnosisResult=""
status=""

webconf_file_exists_count=0
webconf_files=(".htaccess" "httpd.conf" "apache2.conf")

for webconf_file in "${webconf_files[@]}"; do
  find_webconf_files=($(find / -name "$webconf_file" -type f 2>/dev/null))
  for file in "${find_webconf_files[@]}"; do
    ((webconf_file_exists_count++))
    if ! grep -q -i 'ServerTokens.*Prod' "$file"; then
      diagnosisResult="취약"
      status="WARN"
      log_result "WARN" "$file 파일에 ServerTokens Prod 설정이 없습니다."
      append_to_csv "$category" "$code" "$riskLevel" "$diagnosisItem" "$diagnosisResult" "$status"
      cat $TMP1
      echo ; echo
      exit 0
    fi
    if ! grep -q -i 'ServerSignature.*Off' "$file"; then
      diagnosisResult="취약"
      status="WARN"
      log_result "WARN" "$file 파일에 ServerSignature Off 설정이 없습니다."
      append_to_csv "$category" "$code" "$riskLevel" "$diagnosisItem" "$diagnosisResult" "$status"
      cat $TMP1
      echo ; echo
      exit 0
    fi
  done
done

ps_apache_count=$(ps -ef | grep -iE 'httpd|apache2' | grep -v 'grep' | wc -l)
if [ $ps_apache_count -gt 0 ] && [ $webconf_file_exists_count -eq 0 ]; then
  diagnosisResult="취약"
  status="WARN"
  log_result "WARN" "Apache 서비스를 사용하고, ServerTokens Prod, ServerSignature Off를 설정하는 파일이 없습니다."
else
  diagnosisResult="양호"
  status="OK"
  log_result "OK" "웹 서버에서 버전 정보 및 운영체제 정보 노출이 제한되었습니다."
fi

# Append result to CSV
append_to_csv "$category" "$code" "$riskLevel" "$diagnosisItem" "$diagnosisResult" "$status"

# Display the results
cat $TMP1

echo ; echo
