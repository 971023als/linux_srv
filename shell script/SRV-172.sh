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

CODE [SRV-172] 불필요한 시스템 자원 공유 존재

cat << EOF >> $TMP1
[양호]: 불필요한 시스템 자원이 공유되지 않는 경우
[취약]: 불필요한 시스템 자원이 공유되는 경우
EOF

BAR

# Define security details
category="네트워크 보안"
code="SRV-172"
riskLevel="중"
diagnosisItem="불필요한 시스템 자원 공유 존재"
diagnosisResult=""
status=""

# Check NFS shares
nfs_shares=$(showmount -e localhost 2>/dev/null | grep -v "Exports list on localhost:")
if [ -z "$nfs_shares" ]; then
    diagnosisResult="양호"
    status="OK"
    log_result "OK" "NFS에서 불필요한 공유가 존재하지 않습니다."
else
    diagnosisResult="취약"
    status="WARN"
    log_result "WARN" "NFS에서 다음 공유가 발견되었습니다: $nfs_shares"
fi

# Check Samba shares
samba_shares=$(smbstatus -S 2>/dev/null | grep -v "No locked files")
if [ -z "$samba_shares" ]; then
    diagnosisResult="양호"
    status="OK"
    log_result "OK" "Samba에서 불필요한 공유가 존재하지 않습니다."
else
    diagnosisResult="취약"
    status="WARN"
    log_result "WARN" "Samba에서 다음 공유가 발견되었습니다: $samba_shares"
fi

# Append result to CSV
append_to_csv "$category" "$code" "$riskLevel" "$diagnosisItem" "$diagnosisResult" "$status"

# Display the results
cat $TMP1

echo ; echo