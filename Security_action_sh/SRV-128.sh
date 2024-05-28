#!/bin/bash

# 결과 파일 초기화
TMP1="$(SCRIPTNAME).log"
> $TMP1

echo "NTFS 파일 시스템 사용 여부 점검" >> $TMP1
echo "============================" >> $TMP1

# NTFS 파일 시스템 사용 여부 확인
ntfs_check=$(mount | grep 'type ntfs')

if [ -z "$ntfs_check" ]; then
  echo "OK: NTFS 파일 시스템이 사용되지 않습니다." >> $TMP1
else
  echo "WARN: NTFS 파일 시스템이 사용되고 있습니다: $ntfs_check" >> $TMP1
fi

# 결과 출력
cat $TMP1
echo
