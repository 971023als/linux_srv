#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="네트워크 보안"
code="SRV-037"
riskLevel="중"
diagnosisItem="FTP 서비스 실행 상태 검사"
diagnosisResult=""
status=""

BAR

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: FTP 서비스가 비활성화 되어 있는 경우
[취약]: FTP 서비스가 활성화 되어 있는 경우
EOF

BAR

check_ftp_service() {
    local service_file=$1
    local port_setting=$2
    local port_values

    if [ -f "$service_file" ]; then
        port_values=($(grep -vE '^#|^\s#' "$service_file" | grep "$port_setting" | awk -F = '{gsub(" ", "", $0); print $2}'))
        for port in "${port_values[@]}"; do
            local netstat_ftp_count=$(netstat -nat 2>/dev/null | grep -w 'tcp' | grep -Ei 'listen|established|syn_sent|syn_received' | grep ":$port " | wc -l)
            if [ $netstat_ftp_count -gt 0 ]; then
                diagnosisResult="ftp 서비스가 실행 중입니다."
                status="취약"
                echo "WARN: $diagnosisResult" >> $TMP1
                echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
                cat $TMP1
                echo ; echo
                exit 0
            fi
        done
    fi
}

# Check FTP ports in /etc/services
if [ -f /etc/services ]; then
    ftp_ports=($(grep -vE '^#|^\s#' /etc/services | awk 'tolower($1)=="ftp" {print $2}' | awk -F / 'tolower($2)=="tcp" {print $1}'))
    for port in "${ftp_ports[@]}"; do
        netstat_ftp_count=$(netstat -nat 2>/dev/null | grep -w 'tcp' | grep -Ei 'listen|established|syn_sent|syn_received' | grep ":$port " | wc -l)
        if [ $netstat_ftp_count -gt 0 ]; then
            diagnosisResult="ftp 서비스가 실행 중입니다."
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
            echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
            cat $TMP1
            echo ; echo
            exit 0
        fi
    done
fi

# Check vsftpd configuration
vsftpd_files=($(find / -name 'vsftpd.conf' -type f 2>/dev/null))
for file in "${vsftpd_files[@]}"; do
    check_ftp_service "$file" "listen_port"
done

# Check proftpd configuration
proftpd_files=($(find / -name 'proftpd.conf' -type f 2>/dev/null))
for file in "${proftpd_files[@]}"; do
    check_ftp_service "$file" "Port"
done

# Check for running FTP services
ps_ftp_count=$(ps -ef | grep -iE 'ftp|vsftpd|proftp' | grep -v 'grep' | wc -l)
if [ $ps_ftp_count -gt 0 ]; then
    diagnosisResult="ftp 서비스가 실행 중입니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
else
    diagnosisResult="FTP 서비스가 비활성화 되어 있는 경우"
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
fi

# Write the final result to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
