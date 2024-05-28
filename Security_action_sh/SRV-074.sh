#!/bin/bash

TMP1="check_unnecessary_accounts.log"
> $TMP1

echo "불필요하거나 관리되지 않는 계정 검사 시작..." >> $TMP1

if [ -f /etc/passwd ]; then
    # 시스템에서 제거해야 할 불필요한 계정 목록
    unnecessary_accounts="daemon bin sys adm listen nobody nobody4 noaccess diag operator gopher games ftp apache httpd www-data mysql mariadb postgres mail postfix news lp uucp nuucp"
    for account in $unnecessary_accounts; do
        if grep -qwE "^$account:" /etc/passwd; then
            echo "경고: 불필요한 계정($account)이 존재합니다. 해당 계정을 제거하는 것이 권장됩니다." >> $TMP1
            # 사용자 계정을 제거하기 위한 명령어 예시 (주의: 실제로 실행하기 전에 반드시 검토하세요)
            # userdel $account
        fi
    done
fi

if [ -f /etc/group ]; then
    # 관리자 그룹(root)에 등록되어 있으면 안 되는 계정 목록
    root_unnecessary_accounts="daemon bin sys adm listen nobody nobody4 noaccess diag operator gopher games ftp apache httpd www-data mysql mariadb postgres mail postfix news lp uucp nuucp"
    for account in $root_unnecessary_accounts; do
        if grep -q "^root:.*$account" /etc/group; then
            echo "경고: 관리자 그룹(root)에 불필요한 계정($account)이 등록되어 있습니다. 해당 계정을 관리자 그룹에서 제거하는 것이 권장됩니다." >> $TMP1
            # 관리자 그룹에서 사용자 계정을 제거하기 위한 명령어 예시 (주의: 실제로 실행하기 전에 반드시 검토하세요)
            # gpasswd -d $account root
        fi
    done
fi

cat "$TMP1"
echo "검사 완료"
