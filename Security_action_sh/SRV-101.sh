#!/bin/bash

. function.sh

TMP1="$(SCRIPTNAME).log"
> $TMP1

echo "불필요한 예약된 작업 존재 여부 점검" >> $TMP1
echo "==================================" >> $TMP1

# 불필요하거나 위험한 cron 작업의 예시 패턴
suspect_patterns=(
  "/tmp"
  "/var/tmp"
  "wget "
  "curl "
)

# 모든 사용자의 cron 작업을 검사
for user in $(cut -f1 -d: /etc/passwd); do
  crontab -l -u "$user" 2>/dev/null | grep -v '^#' | while read -r cron_job; do
    for pattern in "${suspect_patterns[@]}"; do
      if [[ "$cron_job" == *$pattern* ]]; then
        echo "경고: 사용자 $user 의 cron 작업에서 의심스러운 패턴('$pattern')이 발견되었습니다: $cron_job" >> $TMP1
        break  # 하나의 작업에서 여러 의심스러운 패턴이 발견되어도 한 번만 경고합니다
      fi
    done
  done
done

if ! grep -q "경고" "$TMP1"; then
  echo "불필요한 cron 작업이 존재하지 않습니다." >> $TMP1
fi

# 결과 파일 출력
cat $TMP1
echo
