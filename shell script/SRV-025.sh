#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="시스템 보안"
code="SRV-025"
riskLevel="높음"
diagnosisItem="hosts.equiv 및 .rhosts 파일 보안 검사"
diagnosisResult=""
status=""

BAR

CODE="SRV-025"
diagnosisItem="취약한 hosts.equiv 또는 .rhosts 설정 존재"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: hosts.equiv 및 .rhosts 파일이 없거나, 안전하게 구성된 경우
[취약]: hosts.equiv 또는 .rhosts 파일에 취약한 설정이 있는 경우
EOF

BAR

# Function to check file permissions and settings
check_file_permissions() {
    local file=$1
    local owner=$2
    local filename=$(basename "$file")
    
    if [ -f "$file" ]; then
        file_owner=$(ls -l "$file" | awk '{print $3}')
        if [[ "$file_owner" == "$owner" ]]; then
            file_permission=$(stat -c "%a" "$file")
            if [ "$file_permission" -le 600 ]; then
                if grep -q '+' "$file"; then
                    echo "WARN: $filename 파일에 '+' 설정이 있습니다." >> $TMP1
                    return 1
                else
                    echo "OK: $filename 파일이 안전하게 구성되어 있습니다." >> $TMP1
                    return 0
                fi
            else
                echo "WARN: $filename 파일의 권한이 600보다 큽니다." >> $TMP1
                return 1
            fi
        else
            echo "WARN: $filename 파일의 소유자(owner)가 $owner가 아닙니다." >> $TMP1
            return 1
        fi
    fi
    return 0
}

# Check hosts.equiv file
if [ -f /etc/hosts.equiv ]; then
    if ! check_file_permissions /etc/hosts.equiv root; then
        diagnosisResult="r 계열 서비스를 사용하고, /etc/hosts.equiv 파일에 취약한 설정이 있습니다."
        status="취약"
        echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
        cat $TMP1
        echo ; echo
        exit 0
    fi
fi

# Check .rhosts files in user home directories
user_homedirectories=($(awk -F: '$7!="/bin/false" && $7!="/sbin/nologin" && $6!=null {print $6}' /etc/passwd) $(find /home -maxdepth 1 -type d))
user_owners=($(awk -F: '$7!="/bin/false" && $7!="/sbin/nologin" && $6!=null {print $1}' /etc/passwd) $(find /home -maxdepth 1 -type d | awk -F/ '{print $3}'))

for dir in "${user_homedirectories[@]}"; do
    if [ -f "$dir/.rhosts" ]; then
        owner=$(stat -c "%U" "$dir/.rhosts")
        if ! check_file_permissions "$dir/.rhosts" "$owner"; then
            diagnosisResult="r 계열 서비스를 사용하고, 사용자 홈 디렉터리 내 .rhosts 파일에 취약한 설정이 있습니다."
            status="취약"
            echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
            cat $TMP1
            echo ; echo
            exit 0
        fi
    fi
done

# Check r command services in /etc/xinetd.d
r_command=("rsh" "rlogin" "rexec" "shell" "login" "exec")
if [ -d /etc/xinetd.d ]; then
    for cmd in "${r_command[@]}"; do
        if [ -f /etc/xinetd.d/$cmd ]; then
            if ! grep -qE 'disable\s*=\s*yes' /etc/xinetd.d/$cmd; then
                diagnosisResult="r 계열 서비스를 사용하고, /etc/xinetd.d 디렉터리 내 $cmd 서비스가 활성화되어 있습니다."
                status="취약"
                echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
                cat $TMP1
                echo ; echo
                exit 0
            fi
        fi
    done
fi

# Check r command services in /etc/inetd.conf
if [ -f /etc/inetd.conf ]; then
    for cmd in "${r_command[@]}"; do
        if grep -qvE '^#' /etc/inetd.conf | grep -q $cmd; then
            diagnosisResult="r 계열 서비스를 사용하고, /etc/inetd.conf 파일 내 $cmd 서비스가 활성화되어 있습니다."
            status="취약"
            echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV
            cat $TMP1
            echo ; echo
            exit 0
        fi
    done
fi

diagnosisResult="hosts.equiv 및 .rhosts 파일이 없거나, 안전하게 구성"
status="양호"
echo "OK: $diagnosisResult" >> $TMP1
echo "$category,$CODE,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
