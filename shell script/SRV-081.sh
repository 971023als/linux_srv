=#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $CSV_FILE ]; then
    echo "Category,Code,Risk Level,Diagnosis Item,Service,Diagnosis Result,Status" > $CSV_FILE
fi

# Initial Values
CATEGORY="시스템 권한"
CODE="SRV-081"
RISK_LEVEL="높음"
DIAGNOSIS_ITEM="Crontab 설정 파일 권한 설정"
SERVICE="Account Management"
DIAGNOSIS_RESULT=""
STATUS=""

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,$SERVICE,$result,$status" >> $CSV_FILE
}

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: Crontab 설정 파일의 권한이 적절히 설정된 경우
[취약]: Crontab 설정 파일의 권한이 적절히 설정되지 않은 경우
EOF

BAR

crontab_paths=("/usr/bin/crontab" "/usr/sbin/crontab" "/bin/crontab")
if [ $(which crontab 2>/dev/null | wc -l) -gt 0 ]; then
    crontab_paths+=($(which crontab 2>/dev/null))
fi

for crontab in "${crontab_paths[@]}"; do
    if [ -f $crontab ]; then
        crontab_permission=$(stat -c "%a" $crontab)
        if [ $crontab_permission -gt 750 ]; then
            append_to_csv "${crontab} 명령어의 권한이 750보다 큽니다." "취약"
            continue
        fi
        crontab_group_permission=$(stat -c "%a" $crontab | cut -c2)
        if [ $crontab_group_permission -gt 5 ]; then
            append_to_csv "${crontab} 명령어의 그룹 사용자(group)에 대한 권한이 취약합니다." "취약"
            continue
        fi
        crontab_other_permission=$(stat -c "%a" $crontab | cut -c3)
        if [ $crontab_other_permission -ne 0 ]; then
            append_to_csv "${crontab} 명령어의 다른 사용자(other)에 대한 권한이 취약합니다." "취약"
            continue
        fi
    fi
done

cron_directories=("/etc/cron.hourly" "/etc/cron.daily" "/etc/cron.weekly" "/etc/cron.monthly" "/var/spool/cron" "/var/spool/cron/crontabs")
cron_files=("/etc/crontab" "/etc/cron.allow" "/etc/cron.deny")

for dir in "${cron_directories[@]}"; do
    if [ -d $dir ]; then
        found_files=$(find $dir -type f 2>/dev/null)
        for file in $found_files; do
            cron_files+=($file)
        done
    fi
done

for file in "${cron_files[@]}"; do
    if [ -f $file ]; then
        file_owner=$(stat -c "%U" $file)
        if [ $file_owner != "root" ]; then
            append_to_csv "${file} 파일의 소유자(owner)가 root가 아닙니다." "취약"
            continue
        fi
        file_permission=$(stat -c "%a" $file)
        if [ $file_permission -gt 640 ]; then
            append_to_csv "${file} 파일의 권한이 640보다 큽니다." "취약"
            continue
        fi
        file_group_permission=$(stat -c "%a" $file | cut -c2)
        if [ $file_group_permission -gt 4 ]; then
            append_to_csv "${file} 파일의 그룹 사용자(group)에 대한 권한이 취약합니다." "취약"
            continue
        fi
        file_other_permission=$(stat -c "%a" $file | cut -c3)
        if [ $file_other_permission -ne 0 ]; then
            append_to_csv "${file} 파일의 다른 사용자(other)에 대한 권한이 취약합니다." "취약"
            continue
        fi
    fi
done

append_to_csv "Crontab 설정 파일 권한이 적절히 설정되어 있습니다." "양호"

cat $TMP1

echo "CSV report generated: $CSV_FILE"
echo ; echo
