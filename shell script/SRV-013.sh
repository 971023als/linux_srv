#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="네트워크 보안"
code="SRV-013"
riskLevel="중"
diagnosisItem="Anonymous FTP 접속 제한 설정 검사"
diagnosisResult=""
status=""

BAR

CODE="SRV-013"
diagnosisItem="Anonymous 계정의 FTP 서비스 접속 제한 미비"

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: Anonymous FTP (익명 ftp) 접속을 차단한 경우
[취약]: Anonymous FTP (익명 ftp) 접속을 차단하지 않는 경우
EOF

BAR

if [ -f /etc/passwd ]; then
    if [ $(awk -F : '$1=="ftp" || $1=="anonymous"' /etc/passwd | wc -l) -gt 0 ]; then
        file_exists_count=0
        
        # Check proftpd configuration
        if [ $(find / -name 'proftpd.conf' -type f 2>/dev/null | wc -l) -gt 0 ]; then
            proftpdconf_settings_files=($(find / -name 'proftpd.conf' -type f 2>/dev/null))
            for file in "${proftpdconf_settings_files[@]}"; do
                ((file_exists_count++))
                proftpdconf_anonymous_start_line_count=$(grep -vE '^#|^\s#' "$file" | grep '<Anonymous' | wc -l)
                proftpdconf_anonymous_end_line_count=$(grep -vE '^#|^\s#' "$file" | grep '</Anonymous>' | wc -l)
                if [ $proftpdconf_anonymous_start_line_count -gt 0 ] && [ $proftpdconf_anonymous_end_line_count -gt 0 ]; then
                    proftpdconf_anonymous_start_line=$(grep -vE '^#|^\s#' "$file" | grep -n '<Anonymous' | awk -F : '{print $1}')
                    proftpdconf_anonymous_end_line=$(grep -vE '^#|^\s#' "$file" | grep -n '</Anonymous>' | awk -F : '{print $1}')
                    proftpdconf_anonymous_contents_range=$((proftpdconf_anonymous_end_line-proftpdconf_anonymous_start_line))
                    proftpdconf_anonymous_enable_count=$(grep -vE '^#|^\s#' "$file" | grep -A $proftpdconf_anonymous_contents_range '<Anonymous' | grep -wE 'User|UserAlias' | wc -l)
                    if [ $proftpdconf_anonymous_enable_count -gt 0 ]; then
                        diagnosisResult="${file} 파일에서 'User' 또는 'UserAlias' 옵션이 삭제 또는 주석 처리되어 있지 않습니다."
                        status="취약"
                        echo "WARN: $diagnosisResult" >> $TMP1
                        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
                        cat $TMP1
                        echo ; echo
                        exit 0
                    fi
                fi
            done
        fi

        # Check vsftpd configuration
        if [ $(find / -name 'vsftpd.conf' -type f 2>/dev/null | wc -l) -gt 0 ]; then
            vsftpdconf_settings_files=($(find / -name 'vsftpd.conf' -type f 2>/dev/null))
            for file in "${vsftpdconf_settings_files[@]}"; do
                ((file_exists_count++))
                vsftpdconf_anonymous_enable_count=$(grep -vE '^#|^\s#' "$file" | grep -i 'anonymous_enable' | wc -l)
                if [ $vsftpdconf_anonymous_enable_count -gt 0 ]; then
                    vsftpdconf_anonymous_enable_value=$(grep -vE '^#|^\s#' "$file" | grep -i 'anonymous_enable' | awk '{gsub(" ", "", $0); print tolower($0)}' | awk -F 'anonymous_enable=' '{print $2}')
                    if [[ $vsftpdconf_anonymous_enable_value =~ yes ]]; then
                        diagnosisResult="${file} 파일에서 익명 ftp 접속을 허용하고 있습니다."
                        status="취약"
                        echo "WARN: $diagnosisResult" >> $TMP1
                        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
                        cat $TMP1
                        echo ; echo
                        exit 0
                    fi
                else
                    diagnosisResult="${file} 파일에 익명 ftp 접속을 설정하는 옵션이 없습니다."
                    status="취약"
                    echo "WARN: $diagnosisResult" >> $TMP1
                    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
                    cat $TMP1
                    echo ; echo
                    exit 0
                fi
            done
        fi
        
        if [ $file_exists_count -eq 0 ]; then
            diagnosisResult="익명 ftp 접속을 설정하는 파일이 없습니다."
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
            echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
            cat $TMP1
            echo ; echo
            exit 0
        fi
    fi
fi

diagnosisResult="Anonymous FTP (익명 ftp) 접속을 차단"
status="양호"
echo "OK: $diagnosisResult" >> $TMP1
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1
echo ; echo

cat $OUTPUT_CSV
