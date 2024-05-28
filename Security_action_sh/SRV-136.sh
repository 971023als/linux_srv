#!/bin/bash

# 초기 설정
TMP1="$(SCRIPTNAME).log"
> "$TMP1"

echo "시스템 종료 권한 설정 점검" >> "$TMP1"
echo "=================================" >> "$TMP1"

# 시스템 종료 명령의 경로
shutdown_command="/sbin/shutdown"

# shutdown 명령에 대한 권한 확인 및 조정
if [ -f "$shutdown_command" ]; then
  # 실행 권한 확인
  permissions=$(stat -c %A "$shutdown_command")
  if [[ "$permissions" == *x* ]]; then
    echo "OK: shutdown 명령에 실행 권한이 있습니다." >> "$TMP1"
    # 여기서 추가적인 권한 조정 로직을 구현할 수 있습니다.
    # 예: chmod o-x /sbin/shutdown
  else
    echo "WARN: shutdown 명령에 실행 권한이 없습니다. 권한을 조정합니다." >> "$TMP1"
    # 실행 권한 부여
    chmod +x "$shutdown_command"
    echo "shutdown 명령에 실행 권한을 부여하였습니다." >> "$TMP1"
  fi
else
  echo "WARN: shutdown 명령이 존재하지 않습니다." >> "$TMP1"
fi

# 결과 파일 출력
cat "$TMP1"
echo
