#!/bin/bash

# 불필요한 게스트 계정을 비활성화하는 스크립트
# 참고: 실제 환경에 맞게 계정 이름을 조정해야 할 수 있습니다.

# 불필요한 게스트 계정 이름 정의
GUEST_ACCOUNTS=("guest" "nobody" "ftp" "games")

# 각 게스트 계정에 대해 반복하며 비활성화 조치 실행
for account in "${GUEST_ACCOUNTS[@]}"; do
    if grep -q "^$account:" /etc/passwd; then
        echo "Disabling guest account: $account"
        # 계정을 비활성화합니다. 사용자가 로그인할 수 없도록 /sbin/nologin을 사용합니다.
        usermod -s /sbin/nologin $account 2>/dev/null || {
            echo "Failed to disable $account or it does not exist."
        }
    else
        echo "Account $account does not exist or has already been disabled."
    fi
done

echo "Guest account disablement process complete."
