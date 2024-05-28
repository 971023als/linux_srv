#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
CATEGORY="시스템 보안"
CODE="SRV-084"
RISK_LEVEL="높음"
DIAGNOSIS_ITEM="시스템 핵심 파일 권한 설정"
SERVICE="System Security"
DIAGNOSIS_RESULT=""
STATUS=""

BAR

cat << EOF >> $TMP1
[양호]: 시스템 주요 파일의 권한이 적절하게 설정된 경우
[취약]: 시스템 주요 파일의 권한이 적절하게 설정되지 않은 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,$SERVICE,$result,$status" >> $OUTPUT_CSV
}

TMP1=$(basename "$0").log
> $TMP1

# Check if PATH contains "." or "::"
if [ $(echo $PATH | grep -E '\.:|::' | wc -l) -gt 0 ]; then
    DIAGNOSIS_RESULT="PATH 환경 변수 내에 '.' 또는 '::'이 포함되어 있습니다."
    STATUS="취약"
    append_to_csv "$DIAGNOSIS_RESULT" "$STATUS"
else
    # Additional check for PATH in /etc directory configuration files
    path_settings_files=("/etc/profile" "/etc/.login" "/etc/csh.cshrc" "/etc/csh.login" "/etc/environment")
    for file in "${path_settings_files[@]}"; do
        if [ -f "$file" ]; then
            if [ $(grep -vE '^#|^\s#' "$file" | grep 'PATH=' | grep -E '\.:|::' | wc -l) -gt 0 ]; then
                DIAGNOSIS_RESULT="/etc 디렉터리 내 설정된 PATH 환경 변수에 '.' 또는 '::'이 포함되어 있습니다."
                STATUS="취약"
                append_to_csv "$DIAGNOSIS_RESULT" "$STATUS"
                continue
            fi
        fi
    done

    # Additional check for PATH in user home directory configuration files
    path_settings_files=(".profile" ".cshrc" ".login" ".kshrc" ".bash_profile" ".bashrc" ".bash_login")
    user_homedirectory_path=($(awk -F : '$7!="/bin/false" && $7!="/sbin/nologin" && $6!=null {print $6}' /etc/passwd | uniq))
    user_homedirectory_path+=($(echo /home/*))
    user_homedirectory_path+=("/root")
    
    for homedir in "${user_homedirectory_path[@]}"; do
        for file in "${path_settings_files[@]}"; do
            if [ -f "$homedir/$file" ]; then
                if [ $(grep -vE '^#|^\s#' "$homedir/$file" | grep 'PATH=' | grep -E '\.:|::' | wc -l) -gt 0 ]; then
                    DIAGNOSIS_RESULT="$homedir 디렉터리 내 $file 파일에 설정된 PATH 환경 변수에 '.' 또는 '::'이 포함되어 있습니다."
                    STATUS="취약"
                    append_to_csv "$DIAGNOSIS_RESULT" "$STATUS"
                    continue
                fi
            fi
        done
    done
fi

append_to_csv "PATH 환경 변수에 '.' 또는 '::'이 포함되어 있지 않습니다." "양호"

# Check for home directory permissions
user_homedirectory_path=($(awk -F : '$7!="/bin/false" && $7!="/sbin/nologin" && $6!=null {print $6}' /etc/passwd))
user_homedirectory_path+=($(echo /home/*))
user_homedirectory_owner_name=($(awk -F : '$7!="/bin/false" && $7!="/sbin/nologin" && $6!=null {print $1}' /etc/passwd))
user_homedirectory_owner_name+=($(ls -l /home | awk '{print $3}'))
start_files=(".profile" ".cshrc" ".login" ".kshrc" ".bash_profile" ".bashrc" ".bash_login")

for ((i=0; i<${#user_homedirectory_path[@]}; i++)); do
    for file in "${start_files[@]}"; do
        if [ -f "${user_homedirectory_path[$i]}/$file" ]; then
            owner=$(ls -l "${user_homedirectory_path[$i]}/$file" | awk '{print $3}')
            if [[ "$owner" =~ "root" ]] || [[ "$owner" =~ "${user_homedirectory_owner_name[$i]}" ]]; then
                permission=$(ls -l "${user_homedirectory_path[$i]}/$file" | awk '{print substr($1,9,1)}')
                if [[ "$permission" =~ "w" ]]; then
                    DIAGNOSIS_RESULT="${user_homedirectory_path[$i]} 홈 디렉터리 내 ${file} 환경 변수 파일에 다른 사용자(other)의 쓰기(w) 권한이 부여 되어 있습니다."
                    STATUS="취약"
                    append_to_csv "$DIAGNOSIS_RESULT" "$STATUS"
                    continue
                fi
            else
                DIAGNOSIS_RESULT="${user_homedirectory_path[$i]} 홈 디렉터리 내 ${file} 환경 변수 파일의 소유자(owner)가 root 또는 해당 계정이 아닙니다."
                STATUS="취약"
                append_to_csv "$DIAGNOSIS_RESULT" "$STATUS"
                continue
            fi
        fi
    done
done

append_to_csv "사용자 홈 디렉터리 내 설정 파일의 권한이 적절히 설정되어 있습니다." "양호"

cat $TMP1

echo "CSV report generated: $OUTPUT_CSV"
echo ; echo

cat $OUTPUT_CSV
