#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="시스템 관리"
code="SRV-007"
riskLevel="높음"
diagnosisItem="SMTP 서비스 버전 검사"
service="Account Management"
diagnosisResult=""
status=""

BAR

CODE="SRV-007"
diagnosisItem="취약한 버전의 SMTP 서비스 사용"

# Version comparison function
version_gt() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; }

# Check Sendmail version
SENDMAIL_VERSION=$(/usr/lib/sendmail -d0.1 -bt < /dev/null 2>&1 | grep Version | awk '{print $2}')
SENDMAIL_MIN_VERSION="8.14.9"

if [ -n "$SENDMAIL_VERSION" ]; then
    if version_gt $SENDMAIL_MIN_VERSION $SENDMAIL_VERSION; then
        diagnosisResult="Sendmail 버전이 취약합니다. 현재 버전: $SENDMAIL_VERSION, 권장 최소 버전: $SENDMAIL_MIN_VERSION"
        status="취약"
    else
        diagnosisResult="Sendmail 버전이 안전합니다. 현재 버전: $SENDMAIL_VERSION"
        status="양호"
    fi
else
    diagnosisResult="Sendmail이 설치되어 있지 않습니다."
    status="정보 없음"
fi

# Write the result to CSV for Sendmail
echo "$category,$code,$riskLevel,$diagnosisItem,Sendmail,$diagnosisResult,$status" >> $OUTPUT_CSV

# Reset diagnosisResult and status for Postfix
diagnosisResult=""
status=""

# Check Postfix version
POSTFIX_VERSION=$(postconf -d mail_version 2>/dev/null | awk '{print $3}')
POSTFIX_SAFE_VERSIONS=("2.5.13" "2.6.10" "2.7.4" "2.8.3")

if [ -n "$POSTFIX_VERSION" ]; then
    POSTFIX_VERSION_SAFE=false
    for safe_version in "${POSTFIX_SAFE_VERSIONS[@]}"; do
        if [ "$POSTFIX_VERSION" = "$safe_version" ]; then
            POSTFIX_VERSION_SAFE=true
            break
        fi
    done
    if $POSTFIX_VERSION_SAFE; then
        diagnosisResult="Postfix 버전이 안전합니다. 현재 버전: $POSTFIX_VERSION"
        status="양호"
    else
        diagnosisResult="Postfix 버전이 취약할 수 있습니다. 현재 버전: $POSTFIX_VERSION"
        status="취약"
    fi
else
    diagnosisResult="Postfix가 설치되어 있지 않습니다."
    status="정보 없음"
fi

# Write the result to CSV for Postfix
echo "$category,$code,$riskLevel,$diagnosisItem,Postfix,$diagnosisResult,$status" >> $OUTPUT_CSV

BAR

cat $OUTPUT_CSV
echo ; echo
