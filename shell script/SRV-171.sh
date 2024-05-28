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

CODE [SRV-171] FTP 서비스 정보 노출

cat << EOF >> $TMP1
[양호]: FTP 서버에서 버전 정보 및 기타 세부 정보가 노출되지 않는 경우
[취약]: FTP 서버에서 버전 정보 및 기타 세부 정보가 노출되는 경우
EOF

BAR

# Define security details
category="네트워크 보안"
code="SRV-171"
riskLevel="중"
diagnosisItem="FTP 서비스 정보 노출"
diagnosisResult=""
status=""

# Check vsftpd configuration
vsftpd_config="/etc/vsftpd.conf"
if [ -f "$vsftpd_config" ]; then
    if grep -q 'ftpd_banner=' "$vsftpd_config"; then
        diagnosisResult="양호"
        status="OK"
        log_result "OK" "vsftpd에서 버전 정보 노출이 제한됩니다."
    else
        diagnosisResult="취약"
        status="WARN"
        log_result "WARN" "vsftpd에서 버전 정보가 노출됩니다."
    fi
else
    log_result "INFO" "vsftpd 설정 파일이 존재하지 않습니다."
fi

# Check ProFTPD configuration
proftpd_config="/etc/proftpd/proftpd.conf"
if [ -f "$proftpd_config" ]; then
    if grep -q 'ServerIdent on "FTP Server ready."' "$proftpd_config"; then
        diagnosisResult="양호"
        status="OK"
        log_result "OK" "ProFTPD에서 버전 정보 노출이 제한됩니다."
    else
        diagnosisResult="취약"
        status="WARN"
        log_result "WARN" "ProFTPD에서 버전 정보가 노출됩니다."
    fi
else
    log_result "INFO" "ProFTPD 설정 파일이 존재하지 않습니다."
fi

# Append result to CSV
append_to_csv "$category" "$code" "$riskLevel" "$diagnosisItem" "$diagnosisResult" "$status"

# Display the results
cat $TMP1

echo ; echo
