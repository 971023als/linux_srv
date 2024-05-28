#!/bin/bash

# 초기화 및 로그 파일 설정
TMP1="user_home_directories_check.log"
> "$TMP1"

echo "사용자 홈 디렉터리 설정 검사" >> "$TMP1"
echo "========================================" >> "$TMP1"

# /etc/passwd에서 사용자 홈 디렉터리 정보 추출 및 확인
while IFS=: read -r user _ _ _ _ home_dir _; do
    # 홈 디렉터리의 존재 및 설정 확인
    if [ -d "$home_dir" ] && [ -n "$home_dir" ]; then
        echo "OK: 사용자 $user 의 홈 디렉터리($home_dir)가 적절히 설정되었습니다." >> "$TMP1"
    else
        echo "WARN: 사용자 $user 에 대한 홈 디렉터리($home_dir)가 잘못 설정되었거나 존재하지 않습니다." >> "$TMP1"
    fi
done < /etc/passwd

# 결과 출력 및 로그 파일 생성
cat "$TMP1"
echo
