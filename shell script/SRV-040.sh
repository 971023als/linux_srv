#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="웹 보안"
code="SRV-040"
riskLevel="상"
diagnosisItem="웹 서비스 디렉터리 리스팅 방지 설정 검사"
diagnosisResult=""
status=""

BAR

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 웹 서비스 디렉터리 리스팅이 적절하게 방지된 경우
[취약]: 웹 서비스 디렉터리 리스팅 방지 설정이 미흡한 경우
EOF

BAR

# List of web configuration files to check
webconf_files=(".htaccess" "httpd.conf" "apache2.conf" "userdir.conf")

# Function to check for directory listing in a configuration file
check_directory_listing() {
    local file=$1

    if [[ $file =~ userdir.conf ]]; then
        local userdir_disabled_count=$(grep -vE '^#|^\s#' "$file" | grep -i 'userdir' | grep -i 'disabled' | wc -l)
        if [ $userdir_disabled_count -eq 0 ]; then
            local userdir_indexes_count=$(grep -vE '^#|^\s#' "$file" | grep -i 'Options' | grep -iv '\-indexes' | grep -i 'indexes' | wc -l)
            if [ $userdir_indexes_count -gt 0 ]; then
                diagnosisResult="Apache 설정 파일 $file에 디렉터리 검색 기능이 활성화되어 있습니다."
                status="취약"
                echo "WARN: $diagnosisResult" >> $TMP1
                echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
                cat $TMP1
                echo ; echo
                exit 0
            fi
        fi
    else
        local indexes_count=$(grep -vE '^#|^\s#' "$file" | grep -i 'Options' | grep -iv '\-indexes' | grep -i 'indexes' | wc -l)
        if [ $indexes_count -gt 0 ]; then
            diagnosisResult="Apache 설정 파일 $file에 디렉터리 검색 기능이 활성화되어 있습니다."
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
            echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
            cat $TMP1
            echo ; echo
            exit 0
        fi
    fi
}

# Check each configuration file for directory listing settings
for webconf_file in "${webconf_files[@]}"; do
    find_webconf_files=($(find / -name "$webconf_file" -type f 2>/dev/null))
    for file in "${find_webconf_files[@]}"; do
        check_directory_listing "$file"
    done
done

diagnosisResult="웹 서비스 디렉터리 리스팅이 적절하게 방지된 경우"
status="양호"
echo "OK: $diagnosisResult" >> $TMP1
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
