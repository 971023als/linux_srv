#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="시스템 관리"
code="SRV-010"
riskLevel="중"
diagnosisItem="SMTP 메일 queue 처리 권한 설정 검사"
diagnosisResult=""
status=""

BAR

CODE="SRV-010"
diagnosisItem="SMTP 서비스의 메일 queue 처리 권한 설정 미흡"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

# 결과 파일 정의
TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: SMTP 서비스의 메일 queue 처리 권한을 업무 관리자에게만 부여되도록 설정한 경우
[취약]: SMTP 서비스의 메일 queue 처리 권한이 업무와 무관한 일반 사용자에게도 부여되도록 설정된 경우
EOF

BAR

echo "[SRV-010] SMTP 서비스의 메일 queue 처리 권한 설정 미흡" >> $TMP1

# Sendmail 설정 점검
SENDMAIL_CF="/etc/mail/sendmail.cf"
if [ -f "$SENDMAIL_CF" ]; then
    if grep -q "O PrivacyOptions=.*restrictqrun" "$SENDMAIL_CF"; then
        diagnosisResult="Sendmail의 PrivacyOptions에 restrictqrun 설정이 적용되어 있습니다."
        status="양호"
    else
        diagnosisResult="Sendmail의 PrivacyOptions에 restrictqrun 설정이 누락되었습니다."
        status="취약"
    fi
else
    diagnosisResult="Sendmail 설정 파일이 존재하지 않습니다."
    status="정보 없음"
fi

# Write the result to CSV for Sendmail
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

# Reset diagnosisResult and status for Postfix
diagnosisResult=""
status=""

# Postfix 메일 queue 디렉터리 권한 확인
POSTSUPER="/usr/sbin/postsuper"
if [ -x "$POSTSUPER" ]; then
    # others 권한 점검
    if ls -l "$POSTSUPER" | grep -q "r-xr-x---"; then
        diagnosisResult="Postfix의 postsuper 실행 파일이 others에 대해 실행 권한이 없습니다."
        status="양호"
    else
        diagnosisResult="Postfix의 postsuper 실행 파일이 others에 대해 과도한 권한을 부여하고 있습니다."
        status="취약"
    fi
else
    diagnosisResult="Postfix postsuper 실행 파일이 존재하지 않습니다."
    status="정보 없음"
fi

# Write the result to CSV for Postfix
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

BAR

cat $TMP1
echo ; echo

cat $OUTPUT_CSV
