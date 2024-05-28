#!/bin/bash

# /etc/passwd 파일에서 불필요하게 Shell이 부여된 계정 찾기
unnecessary_accounts=$(grep -E '^(daemon|bin|sys|adm|listen|nobody|nobody4|noaccess|diag|operator|gopher|games|ftp|apache|httpd|www-data|mysql|mariadb|postgres|mail|postfix|news|lp|uucp|nuucp):' /etc/passwd | awk -F: '$7!="/bin/false" && $7!="/sbin/nologin" {print $1}')

# 불필요한 계정이 없는지 확인
if [ -z "$unnecessary_accounts" ]; then
    echo "※ U-53 결과 : 양호(Good) - 불필요하게 Shell이 부여된 계정이 존재하지 않습니다."
    exit 0
fi

# 불필요한 계정의 Shell을 /sbin/nologin으로 변경
echo "다음 계정의 Shell을 변경합니다:"
for account in $unnecessary_accounts; do
    echo "$account"
    usermod -s /sbin/nologin "$account"
    if [ $? -eq 0 ]; then
        echo "$account 계정의 Shell을 /sbin/nologin으로 성공적으로 변경하였습니다."
    else
        echo "$account 계정의 Shell 변경에 실패하였습니다."
    fi
done
