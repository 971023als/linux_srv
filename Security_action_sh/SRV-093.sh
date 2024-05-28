#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

echo "불필요한 world writable 파일 검사 및 조치 스크립트" >> $TMP1
echo "================================================" >> $TMP1

# World writable 파일 탐색
world_writable_files=$(find / -xdev -type f -perm -0002 ! -perm -1000 2>/dev/null)

if [ -n "$world_writable_files" ]; then
    echo "World writable 파일 목록:" >> $TMP1
    echo "$world_writable_files" >> $TMP1
    
    # 파일 권한 수정 여부 결정
    read -p "불필요한 world writable 파일의 권한을 수정하시겠습니까? (y/n): " answer
    if [[ $answer = y* ]] || [[ $answer = Y* ]]; then
        echo "World writable 파일 권한 수정 중..." >> $TMP1
        # 권한 수정
        for file in $world_writable_files; do
            chmod o-w "$file"
            echo "$file 의 권한이 수정되었습니다." >> $TMP1
        done
        echo "모든 world writable 파일의 권한이 수정되었습니다." >> $TMP1
    else
        echo "파일 권한 수정을 건너뜁니다." >> $TMP1
    fi
else
    echo "불필요한 world writable 파일이 존재하지 않습니다." >> $TMP1
fi

cat $TMP1
echo
