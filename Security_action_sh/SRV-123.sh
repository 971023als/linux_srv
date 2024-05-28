#!/bin/bash

# 결과 파일 초기화
TMP1="$(SCRIPTNAME).log"
> $TMP1

echo "최종 로그인 사용자 계정 노출 점검" >> $TMP1
echo "=================================" >> $TMP1

# 로그인 메시지 파일 확인
files=("/etc/motd" "/etc/issue" "/etc/issue.net")

for file in "${files[@]}"; do
  if [ -f "$file" ]; then
    # 'Last login' 문자열 검사
    if grep -q 'Last login' "$file"; then
      echo "WARN: 파일 $file 에 최종 로그인 사용자 정보가 포함되어 있습니다." >> $TMP1
    else
      echo "OK: 파일 $file 에 최종 로그인 사용자 정보가 포함되지 않았습니다." >> $TMP1
    fi
  else
    echo "INFO: 파일 $file 이(가) 존재하지 않습니다." >> $TMP1
  fi
done

# 결과 파일 출력
cat $TMP1
echo
