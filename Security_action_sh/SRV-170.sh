#!/bin/bash

# Postfix 설정 파일
postfix_config="/etc/postfix/main.cf"

# Sendmail 설정 파일
sendmail_config="/etc/mail/sendmail.cf"

# Postfix 설정 확인 및 수정
if [ -f "$postfix_config" ]; then
    # smtpd_banner 설정 확인 및 수정
    if ! grep -q '^smtpd_banner = $myhostname' "$postfix_config"; then
        echo "Postfix 버전 정보 노출 제한 설정을 적용합니다."
        sed -i 's/^smtpd_banner = .*/smtpd_banner = $myhostname/g' "$postfix_config"
        systemctl reload postfix
    else
        echo "Postfix는 이미 버전 정보 노출이 제한된 상태입니다."
    fi
else
    echo "Postfix 서버 설정 파일이 존재하지 않습니다."
fi

# Sendmail 설정 확인 및 수정
if [ -f "$sendmail_config" ]; then
    # SmtpGreetingMessage 설정 확인 및 수정
    if ! grep -q 'O SmtpGreetingMessage=$j' "$sendmail_config"; then
        echo "Sendmail 버전 정보 노출 제한 설정을 적용합니다."
        sed -i 's/^O SmtpGreetingMessage=.*/O SmtpGreetingMessage=$j/g' "$sendmail_config"
        systemctl reload sendmail
    else
        echo "Sendmail은 이미 버전 정보 노출이 제한된 상태입니다."
    fi
else
    echo "Sendmail 서버 설정 파일이 존재하지 않습니다."
fi
