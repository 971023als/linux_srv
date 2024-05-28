#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="웹 보안"
code="SRV-042"
riskLevel="상"
diagnosisItem="상위 디렉터리 접근 제한 설정 검사"
diagnosisResult=""
status=""

BAR

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: DocumentRoot가 별도의 보안 디렉터리로 지정된 경우
[취약]: DocumentRoot가 기본 디렉터리 또는 민감한 디렉터리로 지정된 경우
EOF

BAR

webconf_files=(".htaccess" "httpd.conf" "apache2.conf" "userdir.conf")
file_exists_count=0

check_directory_listing() {
    local file=$1
    local setting
    setting=$(grep -vE '^#|^\s#' "$file" | grep -i 'AllowOverride' | wc -l)
    if [ $setting -gt 0 ]; then
        local allow_override
        allow_override=$(grep -vE '^#|^\s#' "$file" | grep -i 'AllowOverride' | grep -i 'None' | wc -l)
        if [ $allow_override -gt 0 ]; then
            diagnosisResult="웹 서비스 상위 디렉터리에 이동 제한을 설정하지 않았습니다: $file"
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
            echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
            cat $TMP1
            echo ; echo
            exit 0
        fi
    else
        diagnosisResult="웹 서비스 상위 디렉터리에 이동 제한을 설정하지 않았습니다: $file"
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
        echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
        cat $TMP1
        echo ; echo
        exit 0
    fi
}

for webconf_file in "${webconf_files[@]}"; do
    find_webconf_file_count=$(find / -name "$webconf_file" -type f 2>/dev/null | wc -l)
    if [ $find_webconf_file_count -gt 0 ]; then
        ((file_exists_count++))
        find_webconf_files=($(find / -name "$webconf_file" -type f 2>/dev/null))
        for file in "${find_webconf_files[@]}"; do
            if [[ $file =~ userdir.conf ]]; then
                local userdir_disabled
                userdir_disabled=$(grep -vE '^#|^\s#' "$file" | grep -i 'userdir' | grep -i 'disabled' | wc -l)
                if [ $userdir_disabled -eq 0 ]; then
                    check_directory_listing "$file"
                fi
            else
                check_directory_listing "$file"
            fi
        done
    fi
done

ps_apache_count=$(ps -ef | grep -iE 'httpd|apache2' | grep -v 'grep' | wc -l)
if [ $ps_apache_count -gt 0 ] && [ $file_exists_count -eq 0 ]; then
    diagnosisResult="Apache 서비스를 사용하고, 웹 서비스 상위 디렉터리에 이동 제한을 설정하는 파일이 없습니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
else
    diagnosisResult="DocumentRoot가 별도의 보안 디렉터리로 지정된 경우"
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
fi

# Write the final result to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
