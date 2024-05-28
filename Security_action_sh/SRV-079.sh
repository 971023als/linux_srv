#!/bin/bash

# 익명 사용자에게 부적절한 권한이 적용된 파일을 찾고, 권한 변경을 수행하는 스크립트

# 모든 사용자가 쓰기 가능한 파일을 찾음
world_writable_files=$(find / -type f -perm -2 ! -path "/proc/*" ! -path "/sys/*" 2>/dev/null)

# 발견된 파일의 수를 확인
file_count=$(echo "$world_writable_files" | grep -c /)

if [ "$file_count" -gt 0 ]; then
    echo "경고: world writable 설정이 되어 있는 파일이 $file_count 개 있습니다."
    echo "이러한 파일들은 시스템 보안에 위험을 초래할 수 있습니다."

    # 발견된 파일 목록 출력
    echo "아래 파일들의 권한이 world writable로 설정되어 있습니다:"
    echo "$world_writable_files"

    # 사용자에게 권한 변경 여부를 묻기
    read -p "이러한 파일들의 권한을 변경하시겠습니까? (y/N) " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "$world_writable_files" | while read file; do
            chmod o-w "$file"
            echo "권한 변경됨: $file"
        done
        echo "파일 권한 변경이 완료되었습니다."
    else
        echo "파일 권한 변경이 취소되었습니다."
    fi
else
    echo "world writable 설정이 되어 있는 파일이 없습니다. 시스템이 안전합니다."
fi
