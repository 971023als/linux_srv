#!/bin/bash

. function.sh

TMP1=$(basename "$0").log
> $TMP1

BAR

CODE [SRV-005] SMTP 서비스의 expn/vrfy 명령어 실행 제한 미비

cat << EOF >> $TMP1
[양호]: SMTP 서비스가 expn 및 vrfy 명령어 사용을 제한하고 있는 경우
[취약]: SMTP 서비스가 expn 및 vrfy 명령어 사용을 제한하지 않는 경우
EOF

BAR

"[SRV-005] SMTP 서비스의 expn/vrfy 명령어 실행 제한 미비" >> $TMP1

SMTP_SERVICES=("sendmail" "postfix")
POSTFIX_CONFIG="/etc/postfix/main.cf"
SENDMAIL_CONFIG="/etc/mail/sendmail.cf"

for service in "${SMTP_SERVICES[@]}"; do
  if systemctl is-active --quiet $service; then
    echo "$service 서비스가 실행 중입니다." >> $TMP1
    if [[ "$service" == "postfix" && -f "$POSTFIX_CONFIG" ]]; then
      # postfix에서 vrfy 명령어 사용을 제한합니다.
      postconf -e "disable_vrfy_command=yes"
      OK "postfix에서 vrfy 명령어 사용이 자동으로 제한됨" >> $TMP1
      systemctl reload $service
    elif [[ "$service" == "sendmail" && -f "$SENDMAIL_CONFIG" ]]; then
      # sendmail에서 expn, vrfy 명령어 사용을 제한합니다.
      sed -i '/^O PrivacyOptions/ s/$/,noexpn,novrfy/' "$SENDMAIL_CONFIG"
      OK "sendmail에서 expn, vrfy 명령어 사용이 자동으로 제한됨" >> $TMP1
      systemctl restart $service
    fi
  else
    OK "$service 서비스가 비활성화되어 있거나 실행 중이지 않습니다." >> $TMP1
  fi
done

BAR

cat $TMP1
echo ; echo
