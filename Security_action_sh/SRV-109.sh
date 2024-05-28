#!/bin/bash

# 결과 파일 정의
TMP1="$(SCRIPTNAME).log"
> $TMP1

echo "시스템 주요 이벤트 로그 설정 점검" >> $TMP1
echo "=====================================" >> $TMP1

# /etc/rsyslog.conf 파일의 존재 여부 및 내용을 확인합니다
filename="/etc/rsyslog.conf"
if [ ! -e "$filename" ]; then
  echo "$filename 가 존재하지 않습니다" >> $TMP1
else
  # 필요한 로그 설정 내용을 배열로 정의합니다
  expected_content=(
    "*.info;mail.none;authpriv.none;cron.none /var/log/messages"
    "authpriv.* /var/log/secure"
    "mail.* /var/log/maillog"
    "cron.* /var/log/cron"
    "*.alert /dev/console"
    "*.emerg *"
  )

  # 파일 내에서 각 설정이 존재하는지 확인합니다
  match=0
  for content in "${expected_content[@]}"; do
    if grep -q "$content" "$filename"; then
      match=$((match + 1))
    fi
  done

  # 모든 필요한 설정이 존재하는지 결과를 출력합니다
  if [ "$match" -eq "${#expected_content[@]}" ]; then
    echo "$filename의 내용이 정확합니다." >> $TMP1
  else
    echo "$filename의 내용에 일부 설정이 누락되었습니다." >> $TMP1
  fi
fi

# 로그 파일의 권한 설정을 검사합니다
log_files=("/var/log/messages" "/var/log/secure" "/var/log/maillog" "/var/log/cron")
for log_file in "${log_files[@]}"; do
  if [ -e "$log_file" ]; then
    permissions=$(stat -c "%a" "$log_file")
    if [ "$permissions" -le "640" ]; then
      echo "$log_file 파일의 권한이 적절합니다. (권한: $permissions)" >> $TMP1
    else
      echo "$log_file 파일의 권한이 부적절합니다. (권한: $permissions)" >> $TMP1
    fi
  else
    echo "$log_file 파일이 존재하지 않습니다." >> $TMP1
  fi
done

# 결과 파일 출력
cat $TMP1
echo
