#!/bin/bash

# 사용 주의사항 메시지 정의
message="경고: 이 시스템은 권한이 있는 사용자만 사용할 수 있습니다. 모든 활동은 로그로 기록됩니다."

# /etc/motd 파일 조치
motd_file="/etc/motd"
if [ ! -f "$motd_file" ] || [ ! -s "$motd_file" ]; then
    echo "$message" > "$motd_file"
    echo "/etc/motd 파일에 사용 주의사항을 추가했습니다."
else
    echo "/etc/motd 파일이 이미 존재하며 내용이 있습니다."
fi

# /etc/issue 파일 조치
issue_file="/etc/issue"
if [ ! -f "$issue_file" ] || [ ! -s "$issue_file" ]; then
    echo "$message" > "$issue_file"
    echo "/etc/issue 파일에 사용 주의사항을 추가했습니다."
else
    echo "/etc/issue 파일이 이미 존재하며 내용이 있습니다."
fi
