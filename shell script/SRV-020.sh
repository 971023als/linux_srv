#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="네트워크 보안"
code="SRV-020"
riskLevel="중"
diagnosisItem="NFS/SMB/CIFS 공유의 접근 통제 검사"
diagnosisResult=""
status=""

BAR

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: NFS 또는 SMB/CIFS 공유에 대한 접근 통제가 적절하게 설정된 경우
[취약]: NFS 또는 SMB/CIFS 공유에 대한 접근 통제가 미비한 경우
EOF

BAR

# NFS와 SMB/CIFS 설정 파일을 확인합니다.
NFS_EXPORTS_FILE="/etc/exports"
SMB_CONF_FILE="/etc/samba/smb.conf"

check_access_control() {
  file=$1
  service_name=$2

  if [ -f "$file" ]; then
    # 공유 설정에 'everyone' 또는 비슷한 느슨한 설정이 있는지 확인합니다.
    if grep -E "everyone|public" "$file"; then
      diagnosisResult="$service_name 서비스에서 느슨한 공유 접근 통제가 발견됨: $file"
      status="취약"
      echo "WARN: $diagnosisResult" >> $TMP1
    else
      diagnosisResult="$service_name 서비스에서 공유 접근 통제가 적절함: $file"
      status="양호"
      echo "OK: $diagnosisResult" >> $TMP1
    fi
  else
    diagnosisResult="$service_name 서비스 설정 파일($file)을 찾을 수 없습니다."
    status="정보 없음"
    echo "INFO: $diagnosisResult" >> $TMP1
  fi

  # Write the result to CSV
  echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
}

check_nfs_shares() {
  # NFS 공유 목록을 확인합니다.
  showmount -e localhost > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    diagnosisResult="NFS 서비스에서 공유 목록이 발견됨"
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
    showmount -e localhost >> $TMP1
  else
    diagnosisResult="NFS 서비스에서 공유 목록이 발견되지 않음"
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
  fi

  # Write the result to CSV
  echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
}

check_smb_shares() {
  # Samba 공유 목록을 확인합니다.
  smbclient -L localhost -N > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    diagnosisResult="SMB/CIFS 서비스에서 공유 목록이 발견됨"
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
    smbclient -L localhost -N >> $TMP1
  else
    diagnosisResult="SMB/CIFS 서비스에서 공유 목록이 발견되지 않음"
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
  fi

  # Write the result to CSV
  echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
}

check_access_control "$NFS_EXPORTS_FILE" "NFS"
check_access_control "$SMB_CONF_FILE" "SMB/CIFS"
check_nfs_shares
check_smb_shares

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
