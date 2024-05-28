#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

echo "Crontab 파일 및 참조 파일 권한 설정 검사" >> $TMP1
echo "======================================" >> $TMP1

# Crontab 파일 및 주요 참조 파일 목록
files=("/etc/crontab" "/etc/cron.hourly" "/etc/cron.daily" "/etc/cron.weekly" "/etc/cron.monthly" "/etc/cron.d")

# 각 파일의 권한을 검사하고 조치합니다.
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        # 파일 권한을 확인합니다.
        permissions=$(stat -c "%a" "$file")
        # 파일의 권한이 640 이하인지 확인합니다. (root 소유 및 그룹 읽기 권한만 허용)
        if [ "$permissions" -le "640" ]; then
            OK "$file 권한이 적절합니다. (권한: $permissions)" >> $TMP1
        else
            WARN "$file 권한이 부적절합니다. (권한: $permissions). 권한을 조정합니다." >> $TMP1
            chmod 640 "$file"
            echo "$file 권한을 640으로 조정했습니다." >> $TMP1
        fi
    else
        INFO "$file 파일이 존재하지 않습니다." >> $TMP1
    fi
done

cat $TMP1
echo
