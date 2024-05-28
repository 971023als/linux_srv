#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="시스템 보안"
code="SRV-026"
riskLevel="높음"
diagnosisItem="SSH를 통한 Administrator 계정의 원격 접속 제한 검사"
diagnosisResult=""
status=""

BAR

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: SSH를 통한 root 계정의 원격 접속이 제한된 경우
[취약]: SSH를 통한 root 계정의 원격 접속이 제한되지 않은 경우
EOF

BAR

# Check Telnet service settings
if [ -f /etc/services ]; then
    # Check if Telnet port is active
    telnet_port_count=$(grep -vE '^#|^\s#' /etc/services | awk 'tolower($1)=="telnet" {print $2}' | awk -F / 'tolower($2)=="tcp" {print $1}' | wc -l)
    if [ $telnet_port_count -gt 0 ]; then
        telnet_ports=($(grep -vE '^#|^\s#' /etc/services | awk 'tolower($1)=="telnet" {print $2}' | awk -F / 'tolower($2)=="tcp" {print $1}'))
        for port in "${telnet_ports[@]}"; do
            netstat_telnet_count=$(netstat -nat 2>/dev/null | grep -w 'tcp' | grep -Ei 'listen|established|syn_sent|syn_received' | grep ":$port " | wc -l)
            if [ $netstat_telnet_count -gt 0 ]; then
                if [ -f /etc/pam.d/login ]; then
                    pam_securetty_so_count=$(grep -vE '^#|^\s#' /etc/pam.d/login | grep -i 'pam_securetty.so' | wc -l)
                    if [ $pam_securetty_so_count -gt 0 ]; then
                        if [ -f /etc/securetty ]; then
                            etc_securetty_pts_count=$(grep -vE '^#|^\s#' /etc/securetty | grep '^ *pts' | wc -l)
                            if [ $etc_securetty_pts_count -gt 0 ]; then
                                diagnosisResult="telnet 서비스를 사용하고, /etc/securetty 파일에 pts 부분이 제거 또는 주석 처리되어 있지 않습니다."
                                status="취약"
                                echo "WARN: $diagnosisResult" >> $TMP1
                                echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
                                cat $TMP1
                                echo ; echo
                                exit 0
                            fi
                        else
                            diagnosisResult="telnet 서비스를 사용하고, /etc/securetty 파일이 없습니다."
                            status="취약"
                            echo "WARN: $diagnosisResult" >> $TMP1
                            echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
                            cat $TMP1
                            echo ; echo
                            exit 0
                        fi
                    else
                        diagnosisResult="telnet 서비스를 사용하고, /etc/pam.d/login 파일에 pam_securetty.so 모듈이 제거 또는 주석 처리되어 있습니다."
                        status="취약"
                        echo "WARN: $diagnosisResult" >> $TMP1
                        echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
                        cat $TMP1
                        echo ; echo
                        exit 0
                    fi
                else
                    diagnosisResult="telnet 서비스를 사용하고, /etc/pam.d/login 파일이 없습니다."
                    status="취약"
                    echo "WARN: $diagnosisResult" >> $TMP1
                    echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
                    cat $TMP1
                    echo ; echo
                    exit 0
                fi
            fi
        done
    fi
fi

# Check if Telnet service is running
ps_telnet_count=$(ps -ef | grep -i 'telnet' | grep -v 'grep' | wc -l)
if [ $ps_telnet_count -gt 0 ]; then
    if [ -f /etc/pam.d/login ]; then
        pam_securetty_so_count=$(grep -vE '^#|^\s#' /etc/pam.d/login | grep -i 'pam_securetty.so' | wc -l)
        if [ $pam_securetty_so_count -gt 0 ]; then
            if [ -f /etc/securetty ]; then
                etc_securetty_pts_count=$(grep -vE '^#|^\s#' /etc/securetty | grep '^ *pts' | wc -l)
                if [ $etc_securetty_pts_count -gt 0 ]; then
                    diagnosisResult="telnet 서비스를 사용하고, /etc/securetty 파일에 pts 부분이 제거 또는 주석 처리되어 있지 않습니다."
                    status="취약"
                    echo "WARN: $diagnosisResult" >> $TMP1
                    echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
                    cat $TMP1
                    echo ; echo
                    exit 0
                fi
            else
                diagnosisResult="telnet 서비스를 사용하고, /etc/securetty 파일이 없습니다."
                status="취약"
                echo "WARN: $diagnosisResult" >> $TMP1
                echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
                cat $TMP1
                echo ; echo
                exit 0
            fi
        else
            diagnosisResult="telnet 서비스를 사용하고, /etc/pam.d/login 파일에 pam_securetty.so 모듈이 제거 또는 주석 처리되어 있습니다."
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
            echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
            cat $TMP1
            echo ; echo
            exit 0
        fi
    else
        diagnosisResult="telnet 서비스를 사용하고, /etc/pam.d/login 파일이 없습니다."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
        echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
        cat $TMP1
        echo ; echo
        exit 0
    fi
fi

# Check SSH configuration files
sshd_config_files=($(find / -name 'sshd_config' -type f 2> /dev/null))

# Check SSH port configuration and status
if [ -f /etc/services ]; then
    ssh_port_count=$(grep -vE '^#|^\s#' /etc/services | awk 'tolower($1)=="ssh" {print $2}' | awk -F / 'tolower($2)=="tcp" {print $1}' | wc -l)
    if [ $ssh_port_count -gt 0 ]; then
        ssh_ports=($(grep -vE '^#|^\s#' /etc/services | awk 'tolower($1)=="ssh" {print $2}' | awk -F / 'tolower($2)=="tcp" {print $1}'))
        for port in "${ssh_ports[@]}"; do
            netstat_sshd_enable_count=$(netstat -nat 2>/dev/null | grep -w 'tcp' | grep -Ei 'listen|established|syn_sent|syn_received' | grep ":$port " | wc -l)
            if [ $netstat_sshd_enable_count -gt 0 ]; then
                if [ ${#sshd_config_files[@]} -eq 0 ]; then
                    diagnosisResult="ssh 서비스를 사용하고, sshd_config 파일이 없습니다."
                    status="취약"
                    echo "WARN: $diagnosisResult" >> $TMP1
                    echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
                    cat $TMP1
                    echo ; echo
                    exit 0
                fi
                for sshd_config_file in "${sshd_config_files[@]}"; do
                    sshd_permitrootlogin_no_count=$(grep -vE '^#|^\s#' "$sshd_config_file" | grep -i 'permitrootlogin' | grep -i 'no' | wc -l)
                    if [ $sshd_permitrootlogin_no_count -eq 0 ]; then
                        diagnosisResult="ssh 서비스를 사용하고, sshd_config 파일에서 root 계정의 원격 접속이 허용되어 있습니다."
                        status="취약"
                        echo "WARN: $diagnosisResult" >> $TMP1
                        echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
                        cat $TMP1
                        echo ; echo
                        exit 0
                    fi
                done
            fi
        done
    fi
fi

# Check SSH port configuration in sshd_config files
for sshd_config_file in "${sshd_config_files[@]}"; do
    ssh_ports=($(grep -vE '^#|^\s#' "$sshd_config_file" | grep -i 'port' | awk '{print $2}'))
    for port in "${ssh_ports[@]}"; do
        netstat_sshd_enable_count=$(netstat -nat 2>/dev/null | grep -w 'tcp' | grep -Ei 'listen|established|syn_sent|syn_received' | grep ":$port " | wc -l)
        if [ $netstat_sshd_enable_count -gt 0 ]; then
            for sshd_config_file in "${sshd_config_files[@]}"; do
                sshd_permitrootlogin_no_count=$(grep -vE '^#|^\s#' "$sshd_config_file" | grep -i 'permitrootlogin' | grep -i 'no' | wc -l)
                if [ $sshd_permitrootlogin_no_count -eq 0 ]; then
                    diagnosisResult="ssh 서비스를 사용하고, sshd_config 파일에서 root 계정의 원격 접속이 허용되어 있습니다."
                    status="취약"
                    echo "WARN: $diagnosisResult" >> $TMP1
                    echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
                    cat $TMP1
                    echo ; echo
                    exit 0
                fi
            done
        fi
    done
done

# Check if SSH service is running
ps_sshd_enable_count=$(ps -ef | grep -i 'sshd' | grep -v 'grep' | wc -l)
if [ $ps_sshd_enable_count -gt 0 ]; then
    if [ ${#sshd_config_files[@]} -eq 0 ]; then
        diagnosisResult="ssh 서비스를 사용하고, sshd_config 파일이 없습니다."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
        echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
        cat $TMP1
        echo ; echo
        exit 0
    fi
    for sshd_config_file in "${sshd_config_files[@]}"; do
        sshd_permitrootlogin_no_count=$(grep -vE '^#|^\s#' "$sshd_config_file" | grep -i 'permitrootlogin' | grep -i 'no' | wc -l)
        if [ $sshd_permitrootlogin_no_count -eq 0 ]; then
            diagnosisResult="ssh 서비스를 사용하고, sshd_config 파일에서 root 계정의 원격 접속이 허용되어 있습니다."
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
            echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
            cat $TMP1
            echo ; echo
            exit 0
        fi
    done
fi

diagnosisResult="SSH를 통한 root 계정의 원격 접속이 제한"
status="양호"
echo "OK: $diagnosisResult" >> $TMP1
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
