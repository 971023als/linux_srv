#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="네트워크 보안"
code="SRV-018"
riskLevel="중"
diagnosisItem="불필요한 하드디스크 기본 공유 활성화 상태 검사"
diagnosisResult=""
status=""

BAR


# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: NFS 또는 SMB/CIFS의 불필요한 하드디스크 공유가 비활성화된 경우
[취약]: NFS 또는 SMB/CIFS에서 불필요한 하드디스크 기본 공유가 활성화된 경우
EOF

BAR

# NFS와 SMB/CIFS 설정 파일을 확인합니다.
NFS_EXPORTS_FILE="/etc/exports"
SMB_CONF_FILE="/etc/samba/smb.conf"

check_share_activation() {
  file=$1
  service_name=$2

  if [ -f "$file" ]; then
    if grep -E "^\s*\/" "$file" > /dev/null; then
      diagnosisResult="서비스에서 불필요한 공유가 활성화되어 있습니다: $file"
      status="취약"
      echo "WARN: $diagnosisResult" >> $TMP1
    else
      diagnosisResult="서비스에서 불필요한 공유가 비활성화되어 있습니다: $file"
      status="양호"
      echo "OK: $diagnosisResult" >> $TMP1
    fi
  else
    diagnosisResult="서비스 설정 파일($file)을 찾을 수 없습니다."
    status="정보 없음"
    echo "INFO: $diagnosisResult" >> $TMP1
  fi

  # Write the result to CSV
  echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
}

check_share_activation "$NFS_EXPORTS_FILE" "NFS"
check_share_activation "$SMB_CONF_FILE" "SMB/CIFS"

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
