#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="output.csv"
if [ ! -f $CSV_FILE ]; then
    echo "Category,Code,Risk Level,Diagnosis Item,DiagnosisResult,Status" > $CSV_FILE
fi

BAR

CATEGORY="시스템 정책"
CODE="SRV-133"
RISK_LEVEL="높음"
DIAGNOSIS_ITEM="Cron 서비스 사용 계정 제한"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: Cron 서비스 사용이 특정 계정으로 제한되어 있는 경우
[취약]: Cron 서비스 사용이 제한되지 않은 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local category=$1
    local code=$2
    local risk_level=$3
    local diagnosis_item=$4
    local diagnosis_result=$5
    local status=$6
    echo "$category,$code,$risk_level,$diagnosis_item,$diagnosis_result,$status" >> $CSV_FILE
}

# Check crontab permissions
check_crontab_permissions() {
    local crontab_path=("$@")
    for crontab in "${crontab_path[@]}"; do
        if [ -f "$crontab" ]; then
            local crontab_permission=$(stat -c %a "$crontab")
            if [ "$crontab_permission" -gt 750 ]; then
                local result="crontab 명령어의 권한이 750보다 큽니다."
                WARN "$result" >> $TMP1
                append_to_csv "$CATEGORY" "$CODE" "$RISK_LEVEL" "$DIAGNOSIS_ITEM" "$result" "취약"
                exit 0
            fi
        fi
    done
}

# Check cron file permissions
check_cron_file_permissions() {
    local cron_files=("$@")
    for cron_file in "${cron_files[@]}"; do
        if [ -f "$cron_file" ]; then
            local owner=$(stat -c %U "$cron_file")
            local permission=$(stat -c %a "$cron_file")
            if [ "$owner" != "root" ] || [ "$permission" -gt 640 ]; then
                local result="$cron_file 파일의 권한 설정이 잘못되었습니다."
                WARN "$result" >> $TMP1
                append_to_csv "$CATEGORY" "$CODE" "$RISK_LEVEL" "$DIAGNOSIS_ITEM" "$result" "취약"
                exit 0
            fi
        fi
    done
}

# Define crontab paths and cron directories
crontab_path=("/usr/bin/crontab" "/usr/sbin/crontab" "/bin/crontab")
if [ -n "$(which crontab 2>/dev/null)" ]; then
    crontab_path+=("$(which crontab 2>/dev/null)")
fi

cron_directories=("/etc/cron.hourly" "/etc/cron.daily" "/etc/cron.weekly" "/etc/cron.monthly" "/var/spool/cron" "/var/spool/cron/crontabs")
cron_files=("/etc/crontab" "/etc/cron.allow" "/etc/cron.deny")

# Check permissions
check_crontab_permissions "${crontab_path[@]}"
check_cron_file_permissions "${cron_files[@]}"

for dir in "${cron_directories[@]}"; do
    if [ -d "$dir" ]; then
        files=$(find "$dir" -type f 2>/dev/null)
        check_cron_file_permissions $files
    fi
done

# If no issues were found
result="Cron 서비스 사용이 특정 계정으로 제한되어 있습니다."
OK "※ U-22 결과 : 양호(Good)" >> $TMP1
append_to_csv "$CATEGORY" "$CODE" "$RISK_LEVEL" "$DIAGNOSIS_ITEM" "$result" "양호"

cat $TMP1

echo ; echo

cat $CSV_FILE

echo "CSV report generated: $CSV_FILE"
echo ; echo
