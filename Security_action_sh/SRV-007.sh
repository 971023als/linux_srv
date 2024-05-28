#!/bin/bash

. function.sh

TMP1=$(basename "$0").log
> $TMP1
BAR

CODE [SRV-007] 취약한 버전의 SMTP 서비스 사용

cat << EOF >> $TMP1
[양호]: SMTP 서비스 버전이 최신 버전일 경우 또는 취약점이 없는 버전을 사용하는 경우
[취약]: SMTP 서비스 버전이 최신이 아니거나 알려진 취약점이 있는 버전을 사용하는 경우
EOF

BAR

"[SRV-007] 취약한 버전의 SMTP 서비스 사용" >> $TMP1

# Check and upgrade Sendmail version
SENDMAIL_VERSION=$(/usr/lib/sendmail -d0.1 -bt < /dev/null 2>&1 | grep Version | awk '{print $2}')
SENDMAIL_MIN_VERSION="8.14.9"

version_gt() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; }

if [ -n "$SENDMAIL_VERSION" ]; then
    if version_gt $SENDMAIL_MIN_VERSION $SENDMAIL_VERSION; then
        WARN "Sendmail 버전이 취약합니다. 업그레이드를 시도합니다." >> $TMP1
        yum update sendmail -y || apt-get install sendmail -y
        OK "Sendmail 업그레이드 시도됨" >> $TMP1
    else
        OK "Sendmail 버전이 안전합니다. 현재 버전: $SENDMAIL_VERSION" >> $TMP1
    fi
else
    INFO "Sendmail이 설치되어 있지 않습니다." >> $TMP1
fi

# Check and upgrade Postfix version
POSTFIX_VERSION=$(postconf -d mail_version 2>/dev/null)
POSTFIX_SAFE_VERSIONS=("2.5.13" "2.6.10" "2.7.4" "2.8.3")

if [ -n "$POSTFIX_VERSION" ]; then
    POSTFIX_VERSION_SAFE=false
    for safe_version in "${POSTFIX_SAFE_VERSIONS[@]}"; do
        if version_gt $safe_version $POSTFIX_VERSION; then
            POSTFIX_VERSION_SAFE=true
            break
        fi
    done
    if $POSTFIX_VERSION_SAFE; then
        OK "Postfix 버전이 안전합니다. 현재 버전: $POSTFIX_VERSION" >> $TMP1
    else
        WARN "Postfix 버전이 취약할 수 있습니다. 업그레이드를 시도합니다." >> $TMP1
        yum update postfix -y || apt-get install postfix -y
        OK "Postfix 업그레이드 시도됨" >> $TMP1
    fi
else
    INFO "Postfix가 설치되어 있지 않습니다." >> $TMP1
fi

BAR

cat $TMP1
echo ; echo
