#!/bin/bash

# 로그 파일 경로 설정
LOG_FILE="duplicate_uid_accounts.log"

# 로그 파일 초기화
> "$LOG_FILE"

# /etc/passwd 파일에서 UID를 추출하고, 중복된 UID를 가진 계정 식별
awk -F: '{print $3}' /etc/passwd | sort | uniq -d | while read uid; do
    echo "중복 UID 발견: $uid" >> "$LOG_FILE"
    grep ":$uid:" /etc/passwd >> "$LOG_FILE"
done

# 중복 UID가 식별되었는지 확인
if [ -s "$LOG_FILE" ]; then
    echo "중복 UID가 있는 계정이 로깅되었습니다. 로그 파일을 확인해 주세요: $LOG_FILE"
    echo "수동 조치가 필요합니다. 각 계정을 검토하고 적절한 조치를 취하세요."
else
    echo "중복 UID가 있는 계정이 없습니다. 시스템이 양호한 상태입니다."
    rm "$LOG_FILE"
fi
