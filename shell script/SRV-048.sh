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
code="SRV-048"
riskLevel="상"
diagnosisItem="불필요한 웹 서비스 실행 검사"
diagnosisResult=""
status=""

# Define a temporary log file
TMP1=$(basename "$0").log
> $TMP1

# Print bar (assuming BAR is a defined function)
BAR

# Print code and description
echo "[SRV-048] 불필요한 웹 서비스 실행 검사" >> $TMP1

# Append evaluation criteria to the log file
cat << EOF >> $TMP1
[양호]: 불필요한 웹 서비스가 실행되지 않고 있는 경우
[취약]: 불필요한 웹 서비스가 실행되고 있는 경우
EOF

BAR

# 웹 서비스 목록
serverroot_directory=()
webconf_files=(".htaccess" "httpd.conf" "apache2.conf")
for webconf_file in "${webconf_files[@]}"; do
    find_webconf_file_count=$(find / -name "$webconf_file" -type f 2>/dev/null | wc -l)
    if [ $find_webconf_file_count -gt 0 ]; then
        find_webconf_files=($(find / -name "$webconf_file" -type f 2>/dev/null))
        for file in "${find_webconf_files[@]}"; do
            webconf_serverroot_count=$(grep -vE '^#|^\s#' "$file" | grep 'ServerRoot' | grep '/' | wc -l)
            if [ $webconf_serverroot_count -gt 0 ]; then
                serverroot_directory+=($(grep -vE '^#|^\s#' "$file" | grep 'ServerRoot' | grep '/' | awk '{gsub(/"/, "", $0); print $2}'))
            fi
        done
    fi
done

apache2_serverroot_count=$(apache2 -V 2>/dev/null | grep -i 'root' | awk -F '"' '{gsub(" ", "", $0); print $2}' | wc -l)
if [ $apache2_serverroot_count -gt 0 ]; then
    serverroot_directory+=($(apache2 -V 2>/dev/null | grep -i 'root' | awk -F '"' '{gsub(" ", "", $0); print $2}'))
fi

httpd_serverroot_count=$(httpd -V 2>/dev/null | grep -i 'root' | awk -F '"' '{gsub(" ", "", $0); print $2}' | wc -l)
if [ $httpd_serverroot_count -gt 0 ]; then
    serverroot_directory+=($(httpd -V 2>/dev/null | grep -i 'root' | awk -F '"' '{gsub(" ", "", $0); print $2}'))
fi

for directory in "${serverroot_directory[@]}"; do
    manual_file_exists_count=$(find "$directory" -name 'manual' -type f 2>/dev/null | wc -l)
    if [ $manual_file_exists_count -gt 0 ]; then
        diagnosisResult="Apache 홈 디렉터리 내 기본으로 생성되는 불필요한 파일 및 디렉터리가 제거되어 있지 않습니다."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
        echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
        cat $TMP1
        echo ; echo
        exit 0
    fi
done

diagnosisResult="불필요한 웹 서비스가 실행되지 않고 있는 경우"
status="양호"
echo "OK: $diagnosisResult" >> $TMP1

# Write the final result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV

exit 0
