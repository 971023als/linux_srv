#!/bin/bash

# 기본 관리자 계정명(Administrator) 존재 점검 및 조치 스크립트
TMP1=$(basename "$0").log
> $TMP1

echo "기본 관리자 계정명(Administrator) 존재 점검 시작..." >> $TMP1

# 'Administrator' 계정 존재 여부 확인
if grep -qi "^Administrator:" /etc/passwd; then
    echo "경고: 기본 'Administrator' 계정이 존재합니다. 보안 상의 이유로, 해당 계정명을 변경하거나 비활성화하는 것이 권장됩니다." >> $TMP1
    # 여기에 계정명 변경 또는 비활성화를 위한 추가 명령어를 삽입할 수 있습니다. 예:
    # usermod -l NewAdminName Administrator
    # passwd -l Administrator
else
    echo "양호: 기본 'Administrator' 계정이 존재하지 않습니다." >> $TMP1
fi

cat "$TMP1"
echo ; echo
