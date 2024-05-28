#!/bin/bash

TMP1="system_directory_permission_check.log"
> $TMP1

# PATH 환경 변수 검사
if echo $PATH | grep -E '(\.:|::)'; then
    echo "WARN: PATH 환경 변수 내에 현재 디렉터리(.) 또는 빈 경로(::)가 포함되어 있습니다." >> $TMP1
else
    echo "OK: PATH 환경 변수 설정이 적절합니다." >> $TMP1
fi

# /etc 디렉터리 및 사용자 홈 디렉터리의 시작 파일 검사
check_files=("/etc/profile" "/etc/environment" "/etc/bash.bashrc" "/etc/csh.cshrc" "/root/.bashrc")
user_dirs=$(awk -F: '{if ($7 != "/sbin/nologin" && $7 != "/bin/false") print $6}' /etc/passwd)

for file in "${check_files[@]}" $user_dirs/*/.bashrc $user_dirs/*/.profile; do
    if [ -f "$file" ] && grep -Eq 'PATH=.*(\.:|::)' "$file"; then
        echo "WARN: $file 파일에 PATH 환경 변수 설정이 부적절합니다." >> $TMP1
    fi
done

# 사용자 홈 디렉터리 내 시작 파일 권한 검사
for dir in $user_dirs; do
    for start_file in .bashrc .profile .bash_profile .cshrc .login; do
        if [ -f "$dir/$start_file" ] && [ $(stat -c "%a" "$dir/$start_file") -gt 644 ]; then
            echo "WARN: $dir/$start_file 파일의 권한이 644보다 큽니다." >> $TMP1
        fi
    done
done

cat $TMP1
echo
