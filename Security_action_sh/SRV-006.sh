#!/bin/bash

. function.sh

TMP1=$(basename "$0").log
> $TMP1

BAR

CODE [SRV-006] SMTP 서비스 로그 수준 설정 미흡

cat << EOF >> $TMP1
[양호]: SMTP 서비스의 로그 수준이 적절하게 설정되어 있는 경우
[취약]: SMTP 서비스의 로그 수준이 낮거나, 로그가 충분히 수집되지 않는 경우
EOF

BAR

"[SRV-006] SMTP 서비스 로그 수준 설정 미흡" >> $TMP1

SENDMAIL_CONFIG="/etc/mail/sendmail.cf"
LOG_LEVEL_SETTING="O LogLevel"
REQUIRED_LOG_LEVEL=9

# Check and update the LogLevel setting in the sendmail configuration
if [ -f "$SENDMAIL_CONFIG" ]; then
    LOG_LEVEL=$(grep "^$LOG_LEVEL_SETTING" $SENDMAIL_CONFIG | awk '{print $3}')
    if [ -n "$LOG_LEVEL" ] && [ "$LOG_LEVEL" -ge $REQUIRED_LOG_LEVEL ]; then
        OK "SMTP 서비스의 로그 수준이 이미 적절하게 설정됨 (현재 수준: $LOG_LEVEL)." >> $TMP1
    else
        # Update the LogLevel to a more appropriate value
        if grep -q "^$LOG_LEVEL_SETTING" "$SENDMAIL_CONFIG"; then
            # Replace existing LogLevel setting
            sed -i "s/^$LOG_LEVEL_SETTING.*/$LOG_LEVEL_SETTING=$REQUIRED_LOG_LEVEL/" "$SENDMAIL_CONFIG"
        else
            # Add LogLevel setting
            echo "$LOG_LEVEL_SETTING=$REQUIRED_LOG_LEVEL" >> "$SENDMAIL_CONFIG"
        fi
        WARN "SMTP 서비스의 로그 수준을 $REQUIRED_LOG_LEVEL로 조정함." >> $TMP1
        # Consider reloading or restarting the sendmail service to apply changes
        systemctl restart sendmail
    fi
else
    INFO "sendmail 구성 파일($SENDMAIL_CONFIG)을 찾을 수 없습니다." >> $TMP1
fi

BAR

cat $TMP1
echo ; echo
