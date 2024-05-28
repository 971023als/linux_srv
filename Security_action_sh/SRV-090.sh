#!/bin/bash

# 로그 파일 초기화
TMP1="remote_registry_check.log"
> "$TMP1"

echo "원격 레지스트리 서비스 활성화 상태 검사 및 비활성화" >> "$TMP1"
echo "=================================================" >> "$TMP1"

# 원격 레지스트리 서비스 상태 확인
SERVICE_NAME="remote-registry"
if systemctl is-active --quiet $SERVICE_NAME; then
  echo "WARN: 원격 레지스트리 서비스($SERVICE_NAME)가 활성화되어 있습니다. 비활성화를 시도합니다." >> "$TMP1"
  # 원격 레지스트리 서비스 비활성화 시도
  systemctl stop $SERVICE_NAME
  systemctl disable $SERVICE_NAME
  if systemctl is-active --quiet $SERVICE_NAME; then
    echo "ERROR: 원격 레지스트리 서비스($SERVICE_NAME) 비활성화에 실패했습니다." >> "$TMP1"
  else
    echo "OK: 원격 레지스트리 서비스($SERVICE_NAME)가 성공적으로 비활성화되었습니다." >> "$TMP1"
  fi
else
  echo "OK: 원격 레지스트리 서비스($SERVICE_NAME)가 비활성화되어 있습니다." >> "$TMP1"
fi

cat "$TMP1"
echo
