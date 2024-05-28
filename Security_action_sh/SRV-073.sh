#!/bin/bash

# 관리자 그룹에 불필요한 사용자 존재 점검 및 조치 스크립트
TMP1=$(basename "$0").log
> $TMP1

echo "관리자 그룹에 불필요한 사용자 존재 점검 시작..." >> $TMP1

# 관리자 그룹 이름을 정의합니다 (예: sudo, wheel)
admin_group="sudo"

# 관리자 그룹의 멤버 확인
admin_members=$(getent group "$admin_group" | cut -d: -f4)

# 불필요한 사용자 목록을 정의합니다 (예시로 'testuser'가 사용됨)
unnecessary_users=("testuser" "anotheruser") # 실제 환경에 맞게 불필요한 사용자 리스트를 수정하세요.

for user in "${unnecessary_users[@]}"; do
    if [[ $admin_members == *"$user"* ]]; then
        echo "경고: 관리자 그룹($admin_group)에 불필요한 사용자($user)가 포함되어 있습니다. 사용자를 그룹에서 제거하는 것이 권장됩니다." >> $TMP1
        # 여기에 사용자를 그룹에서 제거하기 위한 명령어를 삽입할 수 있습니다. 예:
        # gpasswd -d $user $admin_group
    else
        echo "양호: 관리자 그룹($admin_group)에 불필요한 사용자($user)가 포함되어 있지 않습니다." >> $TMP1
    fi
done

cat "$TMP1"
echo ; echo
