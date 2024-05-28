#!/bin/bash

# 초기 설정
TMP1="$(SCRIPTNAME).log"
> $TMP1

echo "Cron 서비스 사용 계정 제한 점검" >> $TMP1
echo "=================================" >> $TMP1

# crontab 명령 권한 점검
crontab_path=("/usr/bin/crontab" "/usr/sbin/crontab" "/bin/crontab")
if [ "$(which crontab 2>/dev/null)" ]; then
    crontab_path+=("$(which crontab 2>/dev/null)")
fi

for path in "${crontab_path[@]}"; do
    if [ -f "$path" ]; then
        permissions=$(stat -c "%a" "$path")
        if [[ "$permissions" =~ ^[0-7]50$ ]]; then
            echo "OK: $path 권한이 적절하게 설정되어 있습니다. (권한: $permissions)" >> $TMP1
        else
            echo "WARN: $path 권한 설정이 적절하지 않습니다. (권한: $permissions)" >> $TMP1
        fi
    fi
done

# /etc/cron.allow 및 /etc/cron.deny 파일 존재 여부 및 내용 점검
if [ -f "/etc/cron.allow" ]; then
    echo "OK: /etc/cron.allow 파일이 존재합니다." >> $TMP1
else
    echo "INFO: /etc/cron.allow 파일이 존재하지 않습니다." >> $TMP1
fi

if [ -f "/etc/cron.deny" ]; then
    echo "WARN: /etc/cron.deny 파일이 존재합니다. 사용 제한이 필요한 경우 /etc/cron.allow를 사용하세요." >> $TMP1
else
    echo "OK: /etc/cron.deny 파일이 존재하지 않습니다." >> $TMP1
fi

# 결과 파일 출력
cat $TMP1
echo
