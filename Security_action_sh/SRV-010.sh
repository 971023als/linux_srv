#!/bin/bash

. function.sh

# 결과 파일 정의
TMP1=$(basename "$0").log
> $TMP1

BAR

echo "[SRV-010] SMTP 서비스의 메일 queue 처리 권한 설정 조치" >> $TMP1

# Sendmail 설정 조정
SENDMAIL_CF="/etc/mail/sendmail.cf"
if grep -q "O PrivacyOptions=.*restrictqrun" "$SENDMAIL_CF"; then
    echo "OK: Sendmail의 PrivacyOptions에 restrictqrun 설정이 이미 적용되어 있습니다." >> $TMP1
else
    echo "INFO: Sendmail의 PrivacyOptions에 restrictqrun 설정을 적용합니다." >> $TMP1
    sed -i '/^O PrivacyOptions=.*/d' "$SENDMAIL_CF"
    echo "O PrivacyOptions=authwarnings,novrfy,noexpn,restrictqrun" >> "$SENDMAIL_CF"
    echo "APPLIED: Sendmail의 PrivacyOptions에 restrictqrun 설정을 적용하였습니다." >> $TMP1
fi

# Postfix 메일 queue 디렉터리 권한 조정
POSTSUPER="/usr/sbin/postsuper"
if [ -x "$POSTSUPER" ]; then
    # others 권한 조정
    CURRENT_PERMS=$(ls -l "$POSTSUPER" | awk '{print $1}')
    if echo "$CURRENT_PERMS" | grep -q "r-xr-x---"; then
        echo "OK: Postfix의 postsuper 실행 파일이 이미 others에 대해 실행 권한이 없습니다." >> $TMP1
    else
        echo "INFO: Postfix의 postsuper 실행 파일에 대한 권한을 조정합니다." >> $TMP1
        chmod 750 "$POSTSUPER"
        echo "APPLIED: Postfix의 postsuper 실행 파일에 대한 권한을 조정하였습니다." >> $TMP1
    fi
else
    echo "INFO: Postfix postsuper 실행 파일이 존재하지 않습니다." >> $TMP1
fi

cat $TMP1
echo ; echo
