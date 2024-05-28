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
code="SRV-045"
riskLevel="중"
diagnosisItem="웹 서비스 프로세스 권한 제한 미비"
diagnosisResult=""
status=""

# Define a temporary log file
TMP1=$(basename "$0").log
> $TMP1

# Print bar (assuming BAR is a defined function)
BAR

# Print code and description
echo "[SRV-045] 웹 서비스 프로세스 권한 제한 미비" >> $TMP1

# Append evaluation criteria to the log file
cat << EOF >> $TMP1
[양호]: 웹 서비스 프로세스가 root 권한으로 실행되지 않는 경우
[취약]: 웹 서비스 프로세스가 root 권한으로 실행되는 경우
EOF

BAR

# Define configuration files to check
webconf_files=(".htaccess" "httpd.conf" "apache2.conf")

# Iterate over the configuration files
for webconf_file in "${webconf_files[@]}"; do
    find_webconf_files=($(find / -name "$webconf_file" -type f 2>/dev/null))
    
    if [ ${#find_webconf_files[@]} -gt 0 ]; then
        for file in "${find_webconf_files[@]}"; do
            webconf_file_group_root_count=$(grep -vE '^#|^\s#' "$file" | grep -B 1 '^\s*Group' | grep 'root' | wc -l)
            
            if [ $webconf_file_group_root_count -gt 0 ]; then
                diagnosisResult="Apache 데몬이 root 권한으로 구동되도록 설정되어 있습니다: $file"
                status="취약"
                echo "WARN: $diagnosisResult" >> $TMP1
                echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
                cat $TMP1
                echo ; echo
                exit 0
            else
                webconf_file_group=$(grep -vE '^#|^\s#' "$file" | grep '^\s*Group' | awk '{print $2}' | sed 's/{//' | sed 's/}//')
                
                if [ -n "$webconf_file_group" ]; then
                    webconf_file_group_root_count=$(echo "$webconf_file_group" | grep 'root' | wc -l)
                    
                    if [ $webconf_file_group_root_count -gt 0 ]; then
                        diagnosisResult="Apache 데몬이 root 권한으로 구동되도록 설정되어 있습니다: $file"
                        status="취약"
                        echo "WARN: $diagnosisResult" >> $TMP1
                        echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
                        cat $TMP1
                        echo ; echo
                        exit 0
                    fi
                fi
            fi
        done
    fi
done

# If no vulnerabilities were found, print a good status
diagnosisResult="Apache 데몬이 root 권한으로 구동되지 않습니다."
status="양호"
echo "OK: $diagnosisResult" >> $TMP1
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV

exit 0
