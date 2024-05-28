#!/bin/bash

. function.sh

TMP1=$(basename "$0").log
> $TMP1

BAR

CODE [SRV-009] SMTP 서비스 스팸 메일 릴레이 제한 미설정

cat << EOF >> $TMP1
[양호]: SMTP 서비스를 사용하지 않거나 릴레이 제한이 설정되어 있는 경우
[취약]: SMTP 서비스를 사용하거나 릴레이 제한이 설정이 없는 경우
EOF

BAR

# Relay restriction setting for Sendmail
SENDMAIL_CF_FOUND=$(find / -name 'sendmail.cf' -type f 2>/dev/null)

if [ -n "$SENDMAIL_CF_FOUND" ]; then
    for sendmail_cf in $SENDMAIL_CF_FOUND; do
        RELAY_RESTRICTION="R$\* $: $>RelayCheckRcptTo $1"
        if ! grep -q "$RELAY_RESTRICTION" "$sendmail_cf"; then
            echo "$RELAY_RESTRICTION" >> "$sendmail_cf"
            echo "릴레이 제한 설정이 ${sendmail_cf}에 추가되었습니다." >> $TMP1
        else
            echo "${sendmail_cf} 파일은 이미 릴레이 제한이 설정되어 있습니다." >> $TMP1
        fi
    done
else
    echo "Sendmail 설정 파일을 찾을 수 없습니다." >> $TMP1
fi

OK "모든 검사가 완료되었습니다. 필요한 조치가 적용되었습니다." >> $TMP1

cat $TMP1
echo ; echo
