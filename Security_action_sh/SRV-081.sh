#!/bin/bash

# 스크립트 실행 결과를 저장할 로그 파일
TMP1="crontab_permission_check.log"
> $TMP1

# crontab 명령어 및 cron 관련 파일 및 디렉토리 목록
crontab_paths=("/usr/bin/crontab" "/usr/sbin/crontab" "/bin/crontab" "$(which crontab 2>/dev/null)")
cron_dirs=("/etc/cron.hourly" "/etc/cron.daily" "/etc/cron.weekly" "/etc/cron.monthly" "/var/spool/cron" "/var/spool/cron/crontabs")
cron_files=("/etc/crontab" "/etc/cron.allow" "/etc/cron.deny")

# crontab 명령어 권한 검사
for path in "${crontab_paths[@]}"; do
    if [ -f "$path" ]; then
        if [ $(stat -c "%a" "$path") -le 750 ]; then
            echo "OK: $path 권한이 적절합니다." >> $TMP1
        else
            echo "WARN: $path 권한이 750보다 큽니다." >> $TMP1
        fi
    fi
done

# cron 관련 디렉토리 및 파일 권한 검사
for dir in "${cron_dirs[@]}"; do
    find "$dir" -type f -exec stat -c "%n %a" {} \; | while read file perm; do
        if [ "$perm" -gt 640 ]; then
            echo "WARN: $file 권한이 640보다 큽니다." >> $TMP1
        else
            echo "OK: $file 권한이 적절합니다." >> $TMP1
        fi
    done
done

for file in "${cron_files[@]}"; do
    if [ -f "$file" ] && [ $(stat -c "%a" "$file") -gt 640 ]; then
        echo "WARN: $file 권한이 640보다 큽니다." >> $TMP1
    elif [ -f "$file" ]; then
        echo "OK: $file 권한이 적절합니다." >> $TMP1
    fi
done

cat $TMP1
