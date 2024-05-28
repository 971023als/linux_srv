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

CODE [SRV-161] ftpusers 파일의 소유자 및 권한 설정 미흡

cat << EOF >> $TMP1
[양호]: ftpusers 파일의 소유자가 root이고, 권한이 644 이하인 경우
[취약]: ftpusers 파일의 소유자가 root가 아니거나, 권한이 644 이상인 경우
EOF

BAR

# Define security details
category="네트워크 보안"
code="SRV-161"
riskLevel="중"
diagnosisItem="ftpusers 파일의 소유자 및 권한 설정 미흡"
diagnosisResult=""
status=""

# Check ownership and permissions of ftpusers files
file_exists_count=0
ftpusers_files=("/etc/ftpusers" "/etc/pure-ftpd/ftpusers" "/etc/wu-ftpd/ftpusers" "/etc/vsftpd/ftpusers" "/etc/proftpd/ftpusers" "/etc/ftpd/ftpusers" "/etc/vsftpd.ftpusers" "/etc/vsftpd.user_list" "/etc/vsftpd/user_list")

for ftpusers_file in "${ftpusers_files[@]}"; do
  if [ -f "$ftpusers_file" ]; then
    ((file_exists_count++))
    ftpusers_file_owner_name=$(ls -l "$ftpusers_file" | awk '{print $3}')
    if [[ $ftpusers_file_owner_name != "root" ]]; then
      diagnosisResult="취약"
      status="WARN"
      log_result "WARN" " ${ftpusers_file} 파일의 소유자(owner)가 root가 아닙니다."
      append_to_csv "$category" "$code" "$riskLevel" "$diagnosisItem" "$diagnosisResult" "$status"
      cat $TMP1
      echo ; echo
      exit 0
    fi
    ftpusers_file_permission=$(stat -c "%a" "$ftpusers_file")
    if [ $ftpusers_file_permission -gt 644 ]; then
      diagnosisResult="취약"
      status="WARN"
      log_result "WARN" " ${ftpusers_file} 파일의 권한이 644보다 큽니다."
      append_to_csv "$category" "$code" "$riskLevel" "$diagnosisItem" "$diagnosisResult" "$status"
      cat $TMP1
      echo ; echo
      exit 0
    fi
  fi
done

if [ $file_exists_count -eq 0 ]; then
  diagnosisResult="취약"
  status="WARN"
  log_result "WARN" " ftp 접근제어 파일이 없습니다."
else
  diagnosisResult="양호"
  status="OK"
  log_result "OK" "※ U-63 결과 : 양호(Good)"
fi

# Append result to CSV
append_to_csv "$category" "$code" "$riskLevel" "$diagnosisItem" "$diagnosisResult" "$status"

# Display the results
cat $TMP1

echo ; echo