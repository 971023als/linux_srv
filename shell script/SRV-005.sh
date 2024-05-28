#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="시스템 관리"
code="SRV-005"
riskLevel="중"
diagnosisItem="SMTP EXPN/VRFY 명령어 사용 제한 검사"
diagnosisResult=""
status=""

BAR

diagnosisItem="SMTP 서비스의 expn/vrfy 명령어 실행 제한 미비"

# SMTP 서비스 (예: postfix, sendmail)가 실행 중인지 확인하고 expn, vrfy 명령어 사용 제한 확인
SMTP_SERVICES=("sendmail" "postfix")
POSTFIX_CONFIG="/etc/postfix/main.cf"
SENDMAIL_CONFIG="/etc/mail/sendmail.cf"

for service in "${SMTP_SERVICES[@]}"; do
  if systemctl is-active --quiet $service; then
    diagnosisResult="$service 서비스가 실행 중입니다."
    if [[ "$service" == "postfix" && -f "$POSTFIX_CONFIG" ]]; then
      if grep -q "^disable_vrfy_command = yes" "$POSTFIX_CONFIG"; then
        diagnosisResult="$diagnosisResult postfix에서 vrfy 명령어 사용이 제한됨"
        status="양호"
      else
        diagnosisResult="$diagnosisResult postfix에서 vrfy 명령어 사용이 제한되지 않음"
        status="취약"
      fi
    elif [[ "$service" == "sendmail" && -f "$SENDMAIL_CONFIG" ]]; then
      if grep -q "O PrivacyOptions=.*noexpn.*" "$SENDMAIL_CONFIG" && grep -q "O PrivacyOptions=.*novrfy.*" "$SENDMAIL_CONFIG"; then
        diagnosisResult="$diagnosisResult sendmail에서 expn, vrfy 명령어 사용이 제한됨"
        status="양호"
      else
        diagnosisResult="$diagnosisResult sendmail에서 expn, vrfy 명령어 사용이 제한되지 않음"
        status="취약"
      fi
    fi
  else
    diagnosisResult="$service 서비스가 비활성화되어 있거나 실행 중이지 않습니다."
    status="양호"
  fi
  # Write the result to CSV
  echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
done

BAR

cat $OUTPUT_CSV
echo ; echo
