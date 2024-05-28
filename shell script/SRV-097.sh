#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $CSV_FILE ]; then
    echo "Category,Code,Risk Level,Diagnosis Item,Service,DiagnosisResult,Status" > $CSV_FILE
fi

BAR

CATEGORY="네트워크 보안"
CODE="SRV-097"
RISK_LEVEL="중"
DIAGNOSIS_ITEM="FTP 서비스 디렉터리 접근권한 설정 미흡"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: FTP 서비스 디렉터리의 접근 권한이 적절하게 설정된 경우
[취약]: FTP 서비스 디렉터리의 접근 권한이 적절하지 않게 설정된 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,FTP 서비스,$result,$status" >> $CSV_FILE
}

# Check if FTP service is running
check_ftp_service() {
    if [ -f /etc/services ]; then
        ftp_port_count=$(grep -vE '^#|^\s#' /etc/services | awk 'tolower($1)=="ftp" {print $2}' | awk -F / 'tolower($2)=="tcp" {print $1}' | wc -l)
        if [ $ftp_port_count -gt 0 ]; then
            ftp_port=($(grep -vE '^#|^\s#' /etc/services | awk 'tolower($1)=="ftp" {print $2}' | awk -F / 'tolower($2)=="tcp" {print $1}'))
            for port in "${ftp_port[@]}"; do
                netstat_ftp_count=$(netstat -nat 2>/dev/null | grep -w 'tcp' | grep -Ei 'listen|established|syn_sent|syn_received' | grep ":$port " | wc -l)
                if [ $netstat_ftp_count -gt 0 ]; then
                    append_to_csv "FTP 서비스가 실행 중입니다." "취약"
                    return 0
                fi
            done
        fi
    fi
    check_vsftpd
    check_proftpd
    check_ftp_process
    check_ftp_access_files
    append_to_csv "FTP 서비스가 비활성화되어 있습니다." "양호"
}

# Check vsftpd configuration
check_vsftpd() {
    local vsftpdconf_files=($(find / -name 'vsftpd.conf' -type f 2>/dev/null))
    for file in "${vsftpdconf_files[@]}"; do
        if [ -f "$file" ]; then
            local vsftpd_port=$(grep -vE '^#|^\s#' "$file" | grep 'listen_port' | awk -F = '{gsub(" ", "", $0); print $2}')
            if [ -n "$vsftpd_port" ]; then
                local netstat_vsftpd_count=$(netstat -nat 2>/dev/null | grep -w 'tcp' | grep -Ei 'listen|established|syn_sent|syn_received' | grep ":$vsftpd_port " | wc -l)
                if [ $netstat_vsftpd_count -gt 0 ]; then
                    append_to_csv "FTP 서비스가 실행 중입니다." "취약"
                    return 0
                fi
            fi
        fi
    done
}

# Check proftpd configuration
check_proftpd() {
    local proftpdconf_files=($(find / -name 'proftpd.conf' -type f 2>/dev/null))
    for file in "${proftpdconf_files[@]}"; do
        if [ -f "$file" ]; then
            local proftpd_port=$(grep -vE '^#|^\s#' "$file" | grep 'Port' | awk '{print $2}')
            if [ -n "$proftpd_port" ]; then
                local netstat_proftpd_count=$(netstat -nat 2>/dev/null | grep -w 'tcp' | grep -Ei 'listen|established|syn_sent|syn_received' | grep ":$proftpd_port " | wc -l)
                if [ $netstat_proftpd_count -gt 0 ]; then
                    append_to_csv "FTP 서비스가 실행 중입니다." "취약"
                    return 0
                fi
            fi
        fi
    done
}

# Check ftp process
check_ftp_process() {
    local ps_ftp_count=$(ps -ef | grep -iE 'ftp|vsftpd|proftp' | grep -v 'grep' | wc -l)
    if [ $ps_ftp_count -gt 0 ]; then
        append_to_csv "FTP 서비스가 실행 중입니다." "취약"
        return 0
    fi
}

# Check ftp access files
check_ftp_access_files() {
    local ftpusers_files=("/etc/ftpusers" "/etc/pure-ftpd/ftpusers" "/etc/wu-ftpd/ftpusers" "/etc/vsftpd/ftpusers" "/etc/proftpd/ftpusers" "/etc/ftpd/ftpusers" "/etc/vsftpd.ftpusers" "/etc/vsftpd.user_list" "/etc/vsftpd/user_list")
    local file_exists_count=0
    for file in "${ftpusers_files[@]}"; do
        if [ -f "$file" ]; then
            ((file_exists_count++))
            local file_owner=$(ls -l "$file" | awk '{print $3}')
            if [[ "$file_owner" =~ root ]]; then
                local file_permission=$(stat -c "%a" "$file")
                if [ "$file_permission" -le 640 ]; then
                    local file_owner_permission=$(stat -c "%a" "$file" | awk '{print substr($1,1,1)}')
                    local file_group_permission=$(stat -c "%a" "$file" | awk '{print substr($1,2,1)}')
                    local file_other_permission=$(stat -c "%a" "$file" | awk '{print substr($1,3,1)}')
                    if [[ "$file_owner_permission" =~ [6240] ]] && [[ "$file_group_permission" =~ [40] ]] && [[ "$file_other_permission" -eq 0 ]]; then
                        append_to_csv "FTP 접근제어 파일의 권한이 적절하게 설정되어 있습니다." "양호"
                    else
                        append_to_csv "$file 파일의 권한이 적절하지 않습니다." "취약"
                        return 0
                    fi
                else
                    append_to_csv "$file 파일의 권한이 640보다 큽니다." "취약"
                    return 0
                fi
            else
                append_to_csv "$file 파일의 소유자(owner)가 root가 아닙니다." "취약"
                return 0
            fi
        fi
    done
    if [ $file_exists_count -eq 0 ]; then
        append_to_csv "FTP 접근제어 파일이 없습니다." "취약"
    fi
}

# Run the FTP service check
check_ftp_service

cat $TMP1

echo "CSV report generated: $CSV_FILE"
echo ; echo
