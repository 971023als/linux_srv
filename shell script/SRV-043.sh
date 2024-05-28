#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="웹 보안"
code="SRV-043"
riskLevel="중"
diagnosisItem="웹 서비스 경로 내 불필요한 파일 존재 검사"
diagnosisResult=""
status=""

BAR

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 웹 서비스 경로에 불필요한 파일이 존재하지 않는 경우
[취약]: 웹 서비스 경로에 불필요한 파일이 존재하는 경우
EOF

BAR

# List of common unnecessary files in web service directories
UNNECESSARY_FILES=("test.php" "info.php" "example.php" "demo.html" "default.html" "index.html.bak")

# Function to check for unnecessary files in the DocumentRoot
check_unnecessary_files() {
    local dir=$1
    for file in "${UNNECESSARY_FILES[@]}"; do
        if [ -f "$dir/$file" ]; then
            diagnosisResult="불필요한 파일이 웹 서비스 경로에 존재합니다: $file"
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
            echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
            cat $TMP1
            echo ; echo
            exit 0
        fi
    done
}

# Array to store found DocumentRoot directories
document_roots=()

# Search for web configuration files and extract DocumentRoot
webconf_files=(".htaccess" "httpd.conf" "apache2.conf")
for webconf_file in "${webconf_files[@]}"; do
    find_webconf_files=($(find / -name "$webconf_file" -type f 2>/dev/null))
    for file in "${find_webconf_files[@]}"; do
        document_roots+=($(grep -i '^DocumentRoot' "$file" | awk '{print $2}' | tr -d '"'))
    done
done

# Check each DocumentRoot for unnecessary files
for dir in "${document_roots[@]}"; do
    check_unnecessary_files "$dir"
done

# If no unnecessary files found, output as OK
diagnosisResult="웹 서비스 경로에 불필요한 파일이 존재하지 않는 경우"
status="양호"
echo "OK: $diagnosisResult" >> $TMP1
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
