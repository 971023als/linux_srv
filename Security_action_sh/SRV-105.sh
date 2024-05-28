#!/bin/bash

# 결과 파일 정의
TMP1="$(SCRIPTNAME).log"
> $TMP1

echo "불필요한 시작 프로그램 존재 여부 점검" >> $TMP1
echo "=========================================" >> $TMP1

# 시스템 시작 시 실행되는 프로그램 목록 확인
startup_programs=$(systemctl list-unit-files --type=service --state=enabled | awk '{print $1}' | grep -vE 'UNIT FILE|listed')

# 알려진 안전한 서비스 목록
known_safe_services="sshd.service|crond.service|network.service"

# 불필요하거나 의심스러운 서비스를 확인
suspicious_services=0
for service in $startup_programs; do
  if [[ ! $service =~ $known_safe_services ]]; then
    echo "의심스러운 시작 프로그램: $service" >> $TMP1
    suspicious_services=$((suspicious_services+1))
  fi
done

# 결과 출력
if [ $suspicious_services -eq 0 ]; then
    echo "시스템에 불필요한 시작 프로그램이 없습니다." >> $TMP1
else
    echo "검사 결과, 불필요하거나 의심스러운 시작 프로그램이 ${suspicious_services}개 발견되었습니다." >> $TMP1
fi

# 결과 파일 출력
cat $TMP1
echo
