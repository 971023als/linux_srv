#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="네트워크 보안"
code="SRV-021"
riskLevel="중"
diagnosisItem="FTP 서비스 접근 제어 설정 검사"
diagnosisResult=""
status=""

BAR

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: ftpusers 파일의 소유자가 root이고, 권한이 640 이하인 경우
[취약]: ftpusers 파일의 소유자가 root가 아니고, 권한이 640 이상인 경우
EOF

BAR

# FTP 서비스 구성 파일에서 익명 사용자 접속을 확인합니다.
file_exists_count=0
ftpusers_files=("/etc/ftpusers" "/etc/pure-ftpd/ftpusers" "/etc/wu-ftpd/ftpusers" "/etc/vsftpd/ftpusers" "/etc/proftpd/ftpusers" "/etc/ftpd/ftpusers" "/etc/vsftpd.ftpusers" "/etc/vsftpd.user_list" "/etc/vsftpd/user_list")

for file in "${ftpusers_files[@]}"; do
    if [ -f "$file" ]; then
        ((file_exists_count++))
        ftpusers_file_owner_name=$(ls -l "$file" | awk '{print $3}')
        if [[ $ftpusers_file_owner_name == "root" ]]; then
            ftpusers_file_permission=$(stat -c "%a" "$file")
            if [ "$ftpusers_file_permission" -le 640 ]; then
                ftpusers_file_owner_permission=$(stat -c "%A" "$file" | cut -c2-4)
                ftpusers_file_group_permission=$(stat -c "%A" "$file" | cut -c5-7)
                ftpusers_file_other_permission=$(stat -c "%A" "$file" | cut -c8-10)
                if [[ $ftpusers_file_owner_permission =~ [rw-] && $ftpusers_file_group_permission =~ [r-] && $ftpusers_file_other_permission == "---" ]]; then
                    continue
                else
                    diagnosisResult="$file 파일의 권한 설정이 잘못되었습니다."
                    status="취약"
                    echo "WARN: $diagnosisResult" >> $TMP1
                    echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
                    cat $TMP1
                    echo ; echo
                    exit 0
                fi
            else
                diagnosisResult="$file 파일의 권한이 640보다 큽니다."
                status="취약"
                echo "WARN: $diagnosisResult" >> $TMP1
                echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
                cat $TMP1
                echo ; echo
                exit 0
            fi
        else
            diagnosisResult="$file 파일의 소유자(owner)가 root가 아닙니다."
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
            echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
            cat $TMP1
            echo ; echo
            exit 0
        fi
    fi
done

if [ $file_exists_count -eq 0 ]; then
    diagnosisResult="ftp 접근제어 파일이 없습니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
else
    diagnosisResult="ftp 접근제어 파일 설정이 양호합니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
fi

# Write the final result to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1
echo ; echo

cat $OUTPUT_CSV
