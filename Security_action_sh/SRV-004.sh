#!/bin/bash

. function.sh

TMP1=$(basename "$0").log
> $TMP1

BAR

CODE [SRV-004] 불필요한 SMTP 서비스 실행

cat << EOF >> $TMP1
[양호]: SMTP 서비스가 비활성화되어 있거나 필요한 경우에만 실행되는 경우
[취약]: SMTP 서비스가 필요하지 않음에도 실행되고 있는 경우
EOF

BAR

"[SRV-004] 불필요한 SMTP 서비스 실행" >> $TMP1

# SMTP 서비스 (예: postfix)가 실행 중인지 확인합니다.
SMTP_SERVICE="postfix"

if systemctl is-active --quiet $SMTP_SERVICE; then
    # SMTP 서비스 비활성화 명령
    systemctl stop $SMTP_SERVICE
    systemctl disable $SMTP_SERVICE
    WARN "$SMTP_SERVICE 서비스가 중지 및 비활성화되었습니다." >> $TMP1
else
    OK "$SMTP_SERVICE 서비스가 비활성화되어 있거나 실행 중이지 않습니다." >> $TMP1
fi

# Additional check and closure of SMTP service on port 25
SMTP_PORT_STATUS=$(ss -tuln | grep -q ':25 ' && echo "OPEN" || echo "CLOSED")

if [ "$SMTP_PORT_STATUS" = "OPEN" ]; then
    # 포트 25를 닫는 구체적인 조치는 시스템과 설정에 따라 다를 수 있으므로, 이 부분은 일반적인 지침으로 남겨둡니다.
    # 예를 들어, 방화벽 규칙을 사용하여 포트 25를 차단할 수 있습니다.
    # firewall-cmd --permanent --remove-service=smtp
    # firewall-cmd --reload
    WARN "SMTP 포트(25)를 닫는 조치가 필요합니다. 수동 개입이 필요할 수 있습니다." >> $TMP1
else
    OK "SMTP 포트(25)는 닫혀 있습니다." >> $TMP1
fi

BAR

cat $TMP1
echo ; echo
