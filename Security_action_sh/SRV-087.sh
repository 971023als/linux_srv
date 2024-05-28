#!/bin/bash

# 로그 파일 초기화
TMP1="compiler_permission_check.log"
> "$TMP1"

echo "C 컴파일러 존재 및 권한 설정 검사" >> "$TMP1"
echo "======================================" >> "$TMP1"

# C 컴파일러 위치 확인
COMPILER_PATH=$(which gcc 2>/dev/null)

# 컴파일러 존재 여부 및 권한 확인
if [ -z "$COMPILER_PATH" ]; then
  echo "OK: C 컴파일러(gcc)가 시스템에 설치되어 있지 않습니다." >> "$TMP1"
else
  # 권한 확인
  COMPILER_PERMS=$(stat -c "%a" "$COMPILER_PATH" 2>/dev/null)
  if [ "$COMPILER_PERMS" -le "755" ]; then
    echo "OK: C 컴파일러(gcc)의 권한이 적절합니다. 권한: $COMPILER_PERMS" >> "$TMP1"
  else
    echo "WARN: C 컴파일러(gcc)의 권한이 부적절합니다. 권한: $COMPILER_PERMS" >> "$TMP1"
  fi
fi

cat "$TMP1"
echo
