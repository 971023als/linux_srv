#!/bin/bash

# 로그 파일 초기화
TMP1="system_files_permission_check.log"
> "$TMP1"

echo "시스템 주요 파일 권한 설정 검사" >> "$TMP1"
echo "======================================" >> "$TMP1"

# PATH 환경 변수 검사
if echo "$PATH" | grep -qE '(\.:|::)'; then
    echo "WARN: PATH 환경 변수 내에 '.' 또는 '::' 이 포함되어 있습니다." >> "$TMP1"
else
    echo "OK: PATH 환경 변수가 안전하게 설정되어 있습니다." >> "$TMP1"
fi

# /etc 디렉터리와 사용자 홈 디렉터리의 환경 설정 파일 검사
check_files=("/etc/profile" "/etc/bashrc" "$HOME/.bash_profile" "$HOME/.bashrc")
for file in "${check_files[@]}"; do
    if [ -f "$file" ]; then
        if grep -qE 'PATH=.*(\.:|::)' "$file"; then
            echo "WARN: $file 내에 안전하지 않은 PATH 설정이 포함되어 있습니다." >> "$TMP1"
        else
            echo "OK: $file 내의 PATH 설정이 안전합니다." >> "$TMP1"
        fi
    else
        echo "INFO: $file 파일이 존재하지 않습니다." >> "$TMP1"
    fi
done

# 시스템 주요 파일 권한 검사 (예시: /etc/passwd, /etc/shadow 등)
important_files=("/etc/passwd" "/etc/shadow" "/etc/group")
for file in "${important_files[@]}"; do
    if [ -f "$file" ]; then
        permissions=$(stat -c "%a" "$file")
        owner=$(stat -c "%U" "$file")
        if [[ "$permissions" =~ ^[0-7]{3}$ ]] && [ "$owner" = "root" ]; then
            echo "OK: $file 권한이 적절히 설정되어 있습니다. (권한: $permissions, 소유자: $owner)" >> "$TMP1"
        else
            echo "WARN: $file 권한 설정이 적절하지 않습니다. (권한: $permissions, 소유자: $owner)" >> "$TMP1"
        fi
    else
        echo "INFO: $file 파일이 존재하지 않습니다." >> "$TMP1"
    fi
done

cat "$TMP1"
echo
