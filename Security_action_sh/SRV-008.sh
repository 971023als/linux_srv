#!/bin/bash

. function.sh

TMP1=$(basename "$0").log
> $TMP1

BAR

CODE [SRV-008] SMTP 서비스의 DoS 방지 기능 미설정

cat << EOF >> $TMP1
[양호]: SMTP 서비스에 DoS 방지 설정이 적용된 경우
[취약]: SMTP 서비스에 DoS 방지 설정이 적용되지 않은 경우
EOF

BAR

"[SRV-008] SMTP 서비스의 DoS 방지 기능 미설정" >> $TMP1

# Sendmail 설정 점검 및 수정
SENDMAIL_CF="/etc/mail/sendmail.cf"
SENDMAIL_SETTINGS=("MaxDaemonChildren=10" "ConnectionRateThrottle=3" "MinFreeBlocks=100" "MaxHeadersLength=128000" "MaxMessageSize=10485760")

echo "Sendmail DoS 방지 설정을 점검 및 수정 중입니다..." >> $TMP1
if [ -f "$SENDMAIL_CF" ]; then
    for setting in "${SENDMAIL_SETTINGS[@]}"; do
        key=${setting%=*}
        if grep -E -q "^O\s*$key=" "$SENDMAIL_CF"; then
            sed -i "s/^O\s*$key=.*/O $setting/" "$SENDMAIL_CF"
        else
            echo "O $setting" >> "$SENDMAIL_CF"
        fi
        echo "OK: $key 설정이 적용되었습니다." >> $TMP1
    done
else
    echo "INFO: Sendmail 설정 파일이 존재하지 않습니다." >> $TMP1
fi

# Postfix 설정 점검 및 수정
POSTFIX_MAIN_CF="/etc/postfix/main.cf"
POSTFIX_SETTINGS=("message_size_limit=10485760" "header_size_limit=102400" "default_process_limit=10" "local_destination_concurrency_limit=2" "smtpd_recipient_limit=100")

echo "Postfix DoS 방지 설정을 점검 및 수정 중입니다..." >> $TMP1
if [ -f "$POSTFIX_MAIN_CF" ]; then
    for setting in "${POSTFIX_SETTINGS[@]}"; do
        key=${setting%=*}
        if grep -q "^$key" "$POSTFIX_MAIN_CF"; then
            postconf -e "$setting"
        else
            echo "$setting" >> "$POSTFIX_MAIN_CF"
        fi
        echo "OK: $key 설정이 적용되었습니다." >> $TMP1
    done
else
    echo "INFO: Postfix 설정 파일이 존재하지 않습니다." >> $TMP1
fi

# SMTP 서비스 재시작 (설정 적용)
systemctl restart sendmail
systemctl restart postfix

cat $TMP1
echo ; echo
