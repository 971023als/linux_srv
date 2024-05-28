#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="웹 보안"
code="SRV-070"
riskLevel="중"
diagnosisItem="취약한 패스워드 저장 방식 사용"
diagnosisResult=""
status=""

TMP1=$(basename "$0").log
> $TMP1

# Print bar (assuming BAR is a defined function)
BAR

# Print code and description
echo "[SRV-070] 취약한 패스워드 저장 방식 사용" >> $TMP1

# Append evaluation criteria to the log file
cat << EOF >> $TMP1
[양호]: 패스워드 저장에 강력한 해싱 알고리즘을 사용하는 경우
[취약]: 패스워드 저장에 취약한 해싱 알고리즘을 사용하는 경우
EOF

BAR

# 패스워드 해싱 알고리즘 확인
PAM_FILES=("/etc/pam.d/common-password" "/etc/pam.d/system-auth" "/etc/pam.d/password-auth")

# Check for weak algorithms like MD5 and DES
for PAM_FILE in "${PAM_FILES[@]}"; do
    if [ -f "$PAM_FILE" ]; then
        if grep -Eq "md5|des" "$PAM_FILE"; then
            diagnosisResult="취약한 패스워드 해싱 알고리즘이 사용 중입니다: $PAM_FILE"
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
            echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
        else
            diagnosisResult="강력한 패스워드 해싱 알고리즘이 사용 중입니다: $PAM_FILE"
            status="양호"
            echo "OK: $diagnosisResult" >> $TMP1
            echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
        fi
    else
        diagnosisResult="파일이 존재하지 않습니다: $PAM_FILE"
        status="정보 없음"
        echo "INFO: $diagnosisResult" >> $TMP1
        echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
    fi
done

# Output the log file content
cat $TMP1

echo ; echo

# Output the CSV content
cat $OUTPUT_CSV
