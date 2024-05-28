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

CODE [SRV-152] 원격터미널 접속 가능한 사용자 그룹 제한 미비

cat << EOF >> $TMP1
[양호]: SSH 접속이 특정 그룹에게만 제한된 경우
[취약]: SSH 접속이 특정 그룹에게만 제한되지 않은 경우
EOF

BAR

# Define security details
category="네트워크 보안"
code="SRV-152"
riskLevel="중"
diagnosisItem="원격터미널 접속 가능한 사용자 그룹 제한 미비"
diagnosisResult=""
status=""

# sshd_config 파일의 존재 여부를 검색하고, 존재한다면 ssh 서비스가 실행 중일 때 점검할 별도의 배열에 저장함
sshd_config_files=($(find / -name 'sshd_config' -type f 2> /dev/null))
sshd_config_count=${#sshd_config_files[@]}

# Check if SSH service is running
ssh_service_running=false
if [ -f /etc/services ]; then
  ssh_ports=($(grep -vE '^#|^\s#' /etc/services | awk 'tolower($1)=="ssh" {print $2}' | awk -F / 'tolower($2)=="tcp" {print $1}'))
  for port in "${ssh_ports[@]}"; do
    if netstat -nat 2>/dev/null | grep -w 'tcp' | grep -Ei 'listen|established|syn_sent|syn_received' | grep -q ":$port "; then
      ssh_service_running=true
      break
    fi
  done
fi

if ! $ssh_service_running; then
  if ps -ef | grep -i 'sshd' | grep -v 'grep' &> /dev/null; then
    ssh_service_running=true
  fi
fi

# Evaluate SSH configurations
if $ssh_service_running; then
  if [ $sshd_config_count -eq 0 ]; then
    diagnosisResult="취약"
    status="WARN"
    log_result "WARN" "ssh 서비스를 사용하고, sshd_config 파일이 없습니다."
  else
    permitrootlogin_no=true
    for sshd_config in "${sshd_config_files[@]}"; do
      if ! grep -qE '^[^#]*PermitRootLogin\s+no' "$sshd_config"; then
        permitrootlogin_no=false
        break
      fi
    done
    if $permitrootlogin_no; then
      diagnosisResult="양호"
      status="OK"
      log_result "OK" "※ U-01 결과 : 양호(Good)"
    else
      diagnosisResult="취약"
      status="WARN"
      log_result "WARN" "ssh 서비스를 사용하고, sshd_config 파일에서 root 계정의 원격 접속이 허용되어 있습니다."
    fi
  fi
else
  diagnosisResult="양호"
  status="OK"
  log_result "OK" "ssh 서비스가 실행 중이지 않습니다."
fi

# Append result to CSV
append_to_csv "$category" "$code" "$riskLevel" "$diagnosisItem" "$diagnosisResult" "$status"

# Display the results
cat $TMP1

echo ; echo