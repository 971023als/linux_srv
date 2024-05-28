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

CODE [SRV-164] 구성원이 존재하지 않는 GID 존재

cat << EOF >> $TMP1
[양호]: 시스템에 구성원이 존재하지 않는 그룹(GID)가 존재하지 않는 경우
[취약]: 시스템에 구성원이 존재하지 않는 그룹(GID)이 존재하는 경우
EOF

BAR

# Define security details
category="시스템 보안"
code="SRV-164"
riskLevel="중"
diagnosisItem="구성원이 존재하지 않는 GID 존재"
diagnosisResult=""
status=""

# Check for groups without members
unnecessary_groups=($(awk -F: '$3>=500 && $4=="" {print $3}' /etc/group))

for gid in "${unnecessary_groups[@]}"; do
  if ! grep -q ":$gid:" /etc/passwd; then
    diagnosisResult="취약"
    status="WARN"
    log_result "WARN" "구성원이 존재하지 않는 GID($gid)가 존재합니다."
    append_to_csv "$category" "$code" "$riskLevel" "$diagnosisItem" "$diagnosisResult" "$status"
    cat $TMP1
    echo ; echo
    exit 0
  fi
done

diagnosisResult="양호"
status="OK"
log_result "OK" "※ U-51 결과 : 양호(Good)"

# Append result to CSV
append_to_csv "$category" "$code" "$riskLevel" "$diagnosisItem" "$diagnosisResult" "$status"

# Display the results
cat $TMP1

echo ; echo
