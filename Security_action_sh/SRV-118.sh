#!/bin/bash

# 결과 파일 초기화
TMP1="$(SCRIPTNAME).log"
> $TMP1

echo "시스템 보안 패치 및 업데이트 상태 점검" >> $TMP1
echo "=====================================" >> $TMP1

# 시스템 업데이트 상태 확인 (Ubuntu/Debian 기반 시스템)
echo "1. 시스템 패키지 업데이트 확인:" >> $TMP1
apt_update_status=$(apt-get -s upgrade | grep "upgraded,")

if [[ $apt_update_status == *"0 upgraded"* ]]; then
  echo "OK: 모든 패키지가 최신 상태입니다." >> $TMP1
else
  echo "WARN: 일부 패키지가 최신 버전으로 업데이트되지 않았습니다. 업데이트를 확인하세요." >> $TMP1
  echo "$apt_update_status" >> $TMP1
fi

# 보안 권고사항 적용 여부 확인
echo "2. 보안 권고사항 적용 상태 확인:" >> $TMP1
if [ -e "/etc/security/policies.conf" ]; then
  policy_applied=$(grep -E 'important_security_policy' /etc/security/policies.conf)

  if [ ! -z "$policy_applied" ]; then
    echo "OK: 중요 보안 정책이 적용되어 있습니다." >> $TMP1
  else
    echo "WARN: 중요 보안 정책이 /etc/security/policies.conf에 적용되지 않았습니다." >> $TMP1
  fi
else
  echo "WARN: /etc/security/policies.conf 파일이 존재하지 않습니다. 보안 정책 파일을 확인하세요." >> $TMP1
fi

# 결과 파일 출력
cat $TMP1
echo
