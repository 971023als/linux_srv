#!/bin/bash

# CUPS 설정 파일 경로
CUPS_CONFIG_FILE="/etc/cups/cupsd.conf"

# 설정 파일에서 'SystemGroup' 설정 확인
if [ -f "$CUPS_CONFIG_FILE" ]; then
    # 'SystemGroup' 설정이 있는지 확인
    system_group=$(grep -E "^SystemGroup" "$CUPS_CONFIG_FILE")

    if [ -n "$system_group" ]; then
        # 'SystemGroup' 설정이 있을 경우, 양호 메시지 출력
        echo "OK: CUPS 설정에서 시스템 그룹이 지정됨: $system_group"
    else
        # 'SystemGroup' 설정이 없을 경우, 취약 메시지 출력
        echo "WARN: CUPS 설정에서 시스템 그룹이 지정되지 않음"
    fi
else
    # CUPS 설정 파일이 없을 경우, 경고 메시지 출력
    echo "WARN: CUPS 설정 파일($CUPS_CONFIG_FILE)이 존재하지 않습니다."
fi
