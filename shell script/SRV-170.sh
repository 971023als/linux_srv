#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE=$(SCRIPTNAME).csv
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
TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

CODE [SRV-170] SMTP 서비스 정보 노출

cat << EOF >> $TMP1
[양호]: SMTP 서비스에서 버전 정보 및 기타 세부 정보가 노출되지 않는 경우
[취약]: SMTP 서비스에서 버전 정보 및 기타 세부 정보가 노출되는 경우
EOF

BAR

# Define security details
category="네트워크 보안"
code="SRV-170"
riskLevel="중"
diagnosisItem="SMTP 서비스 정보 노출"
diagnosisResult=""
status=""

# Check Postfix configuration
postfix_config="/etc/postfix/main.cf"
if [ -f "$postfix_config" ]; then
    if grep -q '^smtpd_banner = $myhostname' "$postfix_config"; then
        diagnosisResult="양호"
        status="OK"
        log_result "OK" "Postfix에서 버전 정보 노출이 제한됩니다."
    else
        diagnosisResult="취약"
        status="WARN"
        log_result "WARN" "Postfix에서 버전 정보가 노출됩니다."
    fi
else
    log_result "INFO" "Postfix 서버 설정 파일이 존재하지 않습니다."
fi

# Check Sendmail configuration
sendmail_config="/etc/mail/sendmail.cf"
if [ -f "$sendmail_config" ]; then
    if grep -q 'O SmtpGreetingMessage=$j' "$sendmail_config"; then
        diagnosisResult="양호"
        status="OK"
        log_result "OK" "Sendmail에서 버전 정보 노출이 제한됩니다."
    else
        diagnosisResult="취약"
        status="WARN"
        log_result "WARN" "Sendmail에서 버전 정보가 노출됩니다."
    fi
else
    log_result "INFO" "Sendmail 서버 설정 파일이 존재하지 않습니다."
fi

# Append result to CSV
append_to_csv "$category" "$code" "$riskLevel" "$diagnosisItem" "$diagnosisResult" "$status"

# Display the results
cat $TMP1

echo ; echo
