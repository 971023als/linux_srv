#!/bin/bash

# 로그 파일 초기화
TMP1="suid_sgid_files_check.log"
> "$TMP1"

echo "SUID 및 SGID 비트 설정 파일 검사 및 조치" >> "$TMP1"
echo "==========================================" >> "$TMP1"

# SUID 또는 SGID 비트가 설정된 파일 검색
suid_files=$(find / -perm /4000 -type f 2>/dev/null)
sgid_files=$(find / -perm /2000 -type f 2>/dev/null)

# SUID 파일 확인 및 조치
if [ -n "$suid_files" ]; then
    echo "SUID 비트가 설정된 파일이 있습니다:" >> "$TMP1"
    echo "$suid_files" >> "$TMP1"
    # SUID 비트 제거 조치
    # echo "SUID 비트를 제거합니다..." >> "$TMP1"
    # chmod -s $suid_files
else
    echo "SUID 비트가 설정된 불필요한 파일이 없습니다." >> "$TMP1"
fi

# SGID 파일 확인 및 조치
if [ -n "$sgid_files" ]; then
    echo "SGID 비트가 설정된 파일이 있습니다:" >> "$TMP1"
    echo "$sgid_files" >> "$TMP1"
    # SGID 비트 제거 조치
    # echo "SGID 비트를 제거합니다..." >> "$TMP1"
    # chmod -s $sgid_files
else
    echo "SGID 비트가 설정된 불필요한 파일이 없습니다." >> "$TMP1"
fi

# 조치 내용 출력 및 로그 파일 생성
cat "$TMP1"
echo
