#!/bin/bash

# 로그 파일 초기화
TMP1="startup_script_permissions_check.log"
> "$TMP1"

# 시스템 스타트업 스크립트 디렉터리 목록
STARTUP_DIRS=("/etc/init.d" "/etc/rc.d" "/etc/systemd" "/usr/lib/systemd")

echo "시스템 스타트업 스크립트 권한 설정 검사" >> "$TMP1"
echo "======================================" >> "$TMP1"

# 각 스타트업 스크립트의 권한 확인
for dir in "${STARTUP_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    echo "검사 디렉터리: $dir" >> "$TMP1"
    # .sh와 .service 파일을 찾아 권한 확인
    find "$dir" \( -type f -name "*.sh" -o -name "*.service" \) -exec sh -c '
      for script; do
        permissions=$(stat -c "%a" "$script")
        if [ "$permissions" -le "755" ]; then
          echo "OK: $script 스크립트의 권한이 적절합니다. (권한: $permissions)" >> "$TMP1"
        else
          echo "WARN: $script 스크립트의 권한이 적절하지 않습니다. (권한: $permissions)" >> "$TMP1"
        fi
      done
    ' sh {} +
  else
    echo "INFO: $dir 디렉터리가 존재하지 않습니다." >> "$TMP1"
  fi
done

cat "$TMP1"
echo
