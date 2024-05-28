#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="시스템 보안"
code="SRV-023"
riskLevel="높음"
diagnosisItem="SSH 암호화 수준 설정 검사"
diagnosisResult=""
status=""

BAR

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: SSH 서비스의 암호화 수준이 적절하게 설정된 경우
[취약]: SSH 서비스의 암호화 수준 설정이 미흡한 경우
EOF

BAR

# SSH 설정 파일을 확인합니다.
SSH_CONFIG_FILE="/etc/ssh/sshd_config"

# SSH 암호화 관련 설정을 확인합니다.
# 여기서는 예시로 KexAlgorithms, Ciphers, MACs 설정을 확인합니다.
ENCRYPTION_SETTINGS=("KexAlgorithms" "Ciphers" "MACs")

for setting in "${ENCRYPTION_SETTINGS[@]}"; do
  if grep -q "^$setting" "$SSH_CONFIG_FILE"; then
    echo "OK: $SSH_CONFIG_FILE 파일에서 $setting 설정이 적절하게 구성되어 있습니다." >> $TMP1
  else
    echo "WARN: $SSH_CONFIG_FILE 파일에서 $setting 설정이 미흡합니다." >> $TMP1
  fi
done

# Count the number of WARN messages to determine the final result
warn_count=$(grep -c "WARN" $TMP1)

if [ $warn_count -gt 0 ]; then
    diagnosisResult="SSH 서비스의 암호화 수준 설정이 미흡합니다."
    status="취약"
    echo "[결과] 취약: $diagnosisResult" >> $TMP1
else
    diagnosisResult="SSH 서비스의 암호화 수준이 적절하게 설정된 경우."
    status="양호"
    echo "[결과] 양호: $diagnosisResult" >> $TMP1
fi

# Write the final result to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

BAR

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
