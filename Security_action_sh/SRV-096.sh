#!/bin/bash

# 필요한 함수 라이브러리 로드
. function.sh

# 결과 파일 초기화
TMP1="$(SCRIPTNAME).log"
> $TMP1

echo "시스템 보안 검사를 시작합니다..." >> $TMP1
echo "==================================================" >> $TMP1

# 사용자 환경파일 권한 점검
echo "[SRV-096] 사용자 환경파일의 소유자 또는 권한 설정 점검" >> $TMP1
echo "--------------------------------------------------" >> $TMP1

# 사용자 홈 디렉터리 및 소유자 정보 추출
user_homedirectory_path=($(awk -F: '$7!="/bin/false" && $7!="/sbin/nologin" && $6!="" {print $6}' /etc/passwd))
user_homedirectory_owner_name=($(awk -F: '$7!="/bin/false" && $7!="/sbin/nologin" && $6!="" {print $1}' /etc/passwd))

# 시작 파일 검사
start_files=(".profile" ".cshrc" ".login" ".kshrc" ".bash_profile" ".bashrc" ".bash_login")
for i in "${!user_homedirectory_path[@]}"; do
    user="${user_homedirectory_owner_name[$i]}"
    homedir="${user_homedirectory_path[$i]}"
    for file in "${start_files[@]}"; do
        if [ -f "${homedir}/${file}" ]; then
            file_perm=$(stat -c "%a" "${homedir}/${file}")
            file_owner=$(stat -c "%U" "${homedir}/${file}")
            if [ "$file_owner" != "$user" ] || [ "$file_perm" -gt "644" ]; then
                WARN "${homedir}/${file}의 소유자나 권한이 적절하지 않습니다. 소유자: $file_owner, 권한: $file_perm" >> $TMP1
            else
                OK "${homedir}/${file}의 소유자와 권한이 적절합니다." >> $TMP1
            fi
        fi
    done
done

echo "--------------------------------------------------" >> $TMP1

# /etc/hosts.equiv 및 .rhosts 파일 검사
echo "[SRV-094] /etc/hosts.equiv 및 .rhosts 파일 권한 점검" >> $TMP1
echo "--------------------------------------------------" >> $TMP1

# /etc/hosts.equiv 파일 검사
if [ -f "/etc/hosts.equiv" ]; then
    file_perm=$(stat -c "%a" "/etc/hosts.equiv")
    file_owner=$(stat -c "%U" "/etc/hosts.equiv")
    if [ "$file_owner" != "root" ] || [ "$file_perm" -gt "600" ]; then
        WARN "/etc/hosts.equiv 파일의 소유자나 권한이 적절하지 않습니다. 소유자: $file_owner, 권한: $file_perm" >> $TMP1
    else
        OK "/etc/hosts.equiv 파일의 소유자와 권한이 적절합니다." >> $TMP1
    fi
else
    OK "/etc/hosts.equiv 파일이 존재하지 않습니다." >> $TMP1
fi

# 사용자 홈 디렉터리 내 .rhosts 파일 검
