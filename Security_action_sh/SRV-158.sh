#!/bin/bash

# Telnet 서비스 중지 및 비활성화
if systemctl is-active --quiet telnet.socket; then
    echo "Telnet 서비스를 중지하고 비활성화합니다."
    systemctl stop telnet.socket
    systemctl disable telnet.socket
    echo "Telnet 서비스가 중지되고 비활성화되었습니다."
else
    echo "Telnet 서비스는 이미 비활성화되어 있습니다."
fi

# 변경사항 확인
if systemctl is-active --quiet telnet.socket; then
    echo "Telnet 서비스 중지 및 비활성화에 실패했습니다."
else
    echo "Telnet 서비스가 성공적으로 중지 및 비활성화되었습니다."
fi
