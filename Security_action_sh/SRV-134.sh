#!/bin/bash

# 초기 설정
TMP1="$(SCRIPTNAME).log"
> "$TMP1"

echo "스택 영역 실행 방지 설정 점검" >> "$TMP1"
echo "=================================" >> "$TMP1"

# 스택 영역 실행 방지 설정 확인
if grep -q "^kernel.randomize_va_space=2" /etc/sysctl.conf; then
  echo "OK: 스택 영역 실행 방지가 활성화되어 있습니다." >> "$TMP1"
else
  # 스택 영역 실행 방지 설정이 없거나, 다른 값으로 설정되어 있을 경우, 설정 변경
  if grep -q "^kernel.randomize_va_space" /etc/sysctl.conf; then
    # 기존 설정이 있으면 변경
    sed -i 's/^kernel.randomize_va_space=.*/kernel.randomize_va_space=2/' /etc/sysctl.conf
  else
    # 설정이 없으면 추가
    echo "kernel.randomize_va_space=2" >> /etc/sysctl.conf
  fi
  # 변경된 설정 적용
  sysctl -p > /dev/null 2>&1
  echo "WARN: 스택 영역 실행 방지가 비활성화되어 있었습니다. 설정을 변경하여 활성화하였습니다." >> "$TMP1"
fi

# 결과 파일 출력
cat "$TMP1"
echo
