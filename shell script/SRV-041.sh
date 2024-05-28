#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="웹 보안"
code="SRV-041"
riskLevel="중"
diagnosisItem="CGI 스크립트 관리 설정 검사"
diagnosisResult=""
status=""

BAR

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: CGI 스크립트 관리가 적절하게 설정된 경우
[취약]: CGI 스크립트 관리가 미흡한 경우
EOF

BAR

# Apache 설정 파일 확인
APACHE_CONFIG_FILES=("/etc/apache2/apache2.conf" "/etc/httpd/conf/httpd.conf")

check_cgi_settings() {
    local config_file=$1
    if [ -f "$config_file" ]; then
        cgi_exec_option=$(grep -E "^[ \t]*Options.*ExecCGI" "$config_file")
        cgi_handler_directive=$(grep -E "(AddHandler cgi-script|ScriptAlias)" "$config_file")

        if [ -n "$cgi_exec_option" ] || [ -n "$cgi_handler_directive" ]; then
            diagnosisResult="Apache 설정 파일 $config_file 에서 CGI 스크립트 실행이 허용되어 있습니다: $cgi_exec_option, $cgi_handler_directive"
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
            echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
        else
            diagnosisResult="Apache 설정 파일 $config_file 에서 CGI 스크립트 실행이 적절하게 제한되어 있습니다."
            status="양호"
            echo "OK: $diagnosisResult" >> $TMP1
            echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
        fi
    else
        diagnosisResult="Apache 설정 파일 $config_file 을 찾을 수 없습니다."
        status="정보 없음"
        echo "INFO: $diagnosisResult" >> $TMP1
        echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
    fi
}

# Check each Apache configuration file
for config_file in "${APACHE_CONFIG_FILES[@]}"; do
    check_cgi_settings "$config_file"
done

BAR

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
