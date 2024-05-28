#!/bin/bash

# 결과 파일 정의
TMP1="$(SCRIPTNAME).log"
> $TMP1

echo "Cron 서비스 로깅 설정 점검" >> $TMP1
echo "=====================================" >> $TMP1

# rsyslog.conf 파일에서 Cron 로깅 설정 확인 및 수정
rsyslog_conf="/etc/rsyslog.conf"
cron_log_conf="cron.* /var/log/cron"

if [ ! -f "$rsyslog_conf" ]; then
  echo "rsyslog.conf 파일이 존재하지 않습니다." >> $TMP1
else
  if grep -q "cron.*" "$rsyslog_conf"; then
    echo "Cron 로깅이 rsyslog.conf에서 이미 설정되었습니다." >> $TMP1
  else
    echo "Cron 로깅이 rsyslog.conf에서 설정되지 않았습니다. 설정을 추가합니다." >> $TMP1
    echo "$cron_log_conf" >> "$rsyslog_conf"
    systemctl restart rsyslog
    echo "Cron 로깅 설정을 추가하고 rsyslog 서비스를 재시작했습니다." >> $TMP1
  fi
fi

# Cron 로그 파일 존재 여부 확인 및 생성
cron_log="/var/log/cron"
if [ ! -f "$cron_log" ]; then
  echo "Cron 로그 파일이 존재하지 않습니다. 파일을 생성합니다." >> $TMP1
  touch "$cron_log"
  chmod 600 "$cron_log"
  chown root:root "$cron_log"
  echo "Cron 로그 파일을 생성하고 적절한 권한을 설정했습니다." >> $TMP1
else
  echo "Cron 로그 파일이 존재합니다." >> $TMP1
fi

# 결과 파일 출력
cat $TMP1
echo
