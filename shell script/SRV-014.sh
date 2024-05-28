#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="네트워크 보안"
code="SRV-014"
riskLevel="중"
diagnosisItem="NFS 접근통제 미비"
diagnosisResult=""
status=""

BAR

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 불필요한 NFS 서비스를 사용하지 않거나, 불가피하게 사용 시 everyone 공유를 제한한 경우
[취약]: 불필요한 NFS 서비스를 사용하거나, 불가피하게 사용 시 everyone 공유를 제한하지 않는 경우
EOF

BAR

# NFS 설정 파일을 확인합니다.
if [ $(ps -ef | grep -iE 'nfs|rpc.statd|statd|rpc.lockd|lockd' | grep -ivE 'grep|kblockd|rstatd' | wc -l) -gt 0 ]; then
    if [ -f /etc/exports ]; then
        etc_exports_all_count=$(grep -vE '^#|^\s#' /etc/exports | grep '/' | grep '*' | wc -l)
        etc_exports_insecure_count=$(grep -vE '^#|^\s#' /etc/exports | grep '/' | grep -i 'insecure' | wc -l)
        etc_exports_directory_count=$(grep -vE '^#|^\s#' /etc/exports | grep '/' | wc -l)
        etc_exports_squash_count=$(grep -vE '^#|^\s#' /etc/exports | grep '/' | grep -iE 'root_squash|all_squash' | wc -l)
        if [ $etc_exports_all_count -gt 0 ]; then
            diagnosisResult="/etc/exports 파일에 '*' 설정이 있습니다. 모든 클라이언트에 대해 전체 네트워크 공유 허용"
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
        elif [ $etc_exports_insecure_count -gt 0 ]; then
            diagnosisResult="/etc/exports 파일에 'insecure' 옵션이 설정되어 있습니다."
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
        else
            if [ $etc_exports_directory_count -ne $etc_exports_squash_count ]; then
                diagnosisResult="/etc/exports 파일에 'root_squash' 또는 'all_squash' 옵션이 설정되어 있지 않습니다."
                status="취약"
                echo "WARN: $diagnosisResult" >> $TMP1
            else
                diagnosisResult="불필요한 NFS 서비스를 사용하지 않거나, 불가피하게 사용 시 everyone 공유를 제한"
                status="양호"
                echo "OK: $diagnosisResult" >> $TMP1
            fi
        fi
    else
        diagnosisResult="NFS 설정 파일(/etc/exports)을 찾을 수 없습니다."
        status="정보 없음"
        echo "INFO: $diagnosisResult" >> $TMP1
    fi
else
    diagnosisResult="불필요한 NFS 서비스를 사용하지 않거나, 불가피하게 사용 시 everyone 공유를 제한"
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
fi

# Write the result to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

BAR

cat $TMP1
echo ; echo

cat $OUTPUT_CSV
