#!/bin/bash

# Load external functions from function.sh
. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="웹 보안"
code="SRV-047"
riskLevel="싱"
diagnosisItem="웹 서비스 경로 내 불필요한 링크 파일 검사"
diagnosisResult=""
status=""

# Define a temporary log file
TMP1=$(basename "$0").log
> $TMP1

# Print bar (assuming BAR is a defined function)
BAR

# Print code and description
echo "[SRV-047] 웹 서비스 경로 내 불필요한 링크 파일 검사" >> $TMP1

# Append evaluation criteria to the log file
cat << EOF >> $TMP1
[양호]: 웹 서비스 경로 내 불필요한 심볼릭 링크 파일이 존재하지 않는 경우
[취약]: 웹 서비스 경로 내 불필요한 심볼릭 링크 파일이 존재하는 경우
EOF

BAR

# Define configuration files to check
webconf_files=(".htaccess" "httpd.conf" "apache2.conf" "userdir.conf")

# Check each configuration file
for webconf_file in "${webconf_files[@]}"; do
    find_webconf_file_count=$(find / -name "$webconf_file" -type f 2>/dev/null | wc -l)
    if [ $find_webconf_file_count -gt 0 ]; then
        find_webconf_files=($(find / -name "$webconf_file" -type f 2>/dev/null))
        for file in "${find_webconf_files[@]}"; do
            if [[ $file =~ userdir.conf ]]; then
                userdirconf_disabled_count=$(grep -vE '^#|^\s#' "$file" | grep -i 'userdir' | grep -i 'disabled' | wc -l)
                if [ $userdirconf_disabled_count -eq 0 ]; then
                    userdirconf_followsymlinks_count=$(grep -vE '^#|^\s#' "$file" | grep -i 'Options' | grep -iv '\-FollowSymLinks' | grep -i 'FollowSymLinks' | wc -l)
                    if [ $userdirconf_followsymlinks_count -gt 0 ]; then
                        diagnosisResult="Apache 설정 파일에 심볼릭 링크 사용을 제한하도록 설정하지 않았습니다."
                        status="취약"
                        echo "WARN: $diagnosisResult" >> $TMP1
                        echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
                        cat $TMP1
                        echo ; echo
                        exit 0
                    fi
                fi
            else
                webconf_file_followSymlinks_count=$(grep -vE '^#|^\s#' "$file" | grep -i 'Options' | grep -iv '\-FollowSymLinks' | grep -i 'FollowSymLinks' | wc -l)
                if [ $webconf_file_followSymlinks_count -gt 0 ]; then
                    diagnosisResult="Apache 설정 파일에 심볼릭 링크 사용을 제한하도록 설정하지 않았습니다."
                    status="취약"
                    echo "WARN: $diagnosisResult" >> $TMP1
                    echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
                    cat $TMP1
                    echo ; echo
                    exit 0
                fi
            fi
        done
    fi
done

diagnosisResult="웹 서비스 경로 내 불필요한 심볼릭 링크 파일이 존재하지 않는 경우"
status="양호"
echo "OK: $diagnosisResult" >> $TMP1

# Write the final result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV

exit 0
