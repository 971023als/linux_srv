#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $CSV_FILE ]; then
    echo "Category,Code,Risk Level,Diagnosis Item,DiagnosisResult,Status" > $CSV_FILE
fi

BAR

CATEGORY="시스템 보안"
CODE="SRV-121"
RISK_LEVEL="중"
DIAGNOSIS_ITEM="root 계정의 PATH 환경변수 설정 미흡"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: root 계정의 PATH 환경변수가 안전하게 설정되어 있는 경우
[취약]: root 계정의 PATH 환경변수에 안전하지 않은 경로가 포함된 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,$SERVICE,$result,$status" >> $CSV_FILE
}

# Check root PATH environment variable
if echo $PATH | grep -E '\.:|::' > /dev/null; then
    DiagnosisResult="PATH 환경 변수 내에 '.' 또는 '::'이 포함되어 있습니다."
    Status="취약"
    append_to_csv "$DiagnosisResult" "$Status"
else
    # Check for PATH settings in configuration files
    path_settings_files=("/etc/profile" "/etc/.login" "/etc/csh.cshrc" "/etc/csh.login" "/etc/environment")
    vulnerable=false

    for file in "${path_settings_files[@]}"; do
        if [ -f "$file" ]; then
            if grep -vE '^#|^\s#' "$file" | grep 'PATH=' | grep -E '\.:|::' > /dev/null; then
                DiagnosisResult="/etc 디렉터리 내 $file 파일에 설정된 PATH 환경 변수 내에 '.' 또는 '::'이 포함되어 있습니다."
                Status="취약"
                append_to_csv "$DiagnosisResult" "$Status"
                vulnerable=true
                break
            fi
        fi
    done

    if [ "$vulnerable" = false ]; then
        path_settings_files=(".profile" ".cshrc" ".login" ".kshrc" ".bash_profile" ".bashrc" ".bash_login")
        user_homedirectory_path=($(awk -F : '$7!="/bin/false" && $7!="/sbin/nologin" && $6!="" {print $6}' /etc/passwd | uniq))
        user_homedirectory_path+=("/home/*" "/root")

        for user_home in "${user_homedirectory_path[@]}"; do
            for file in "${path_settings_files[@]}"; do
                if [ -f "$user_home/$file" ]; then
                    if grep -vE '^#|^\s#' "$user_home/$file" | grep 'PATH=' | grep -E '\.:|::' > /dev/null; then
                        DiagnosisResult="$user_home 디렉터리 내 $file 파일에 설정된 PATH 환경 변수 내에 '.' 또는 '::'이 포함되어 있습니다."
                        Status="취약"
                        append_to_csv "$DiagnosisResult" "$Status"
                        vulnerable=true
                        break 2
                    fi
                fi
            done
        done
    fi

    if [ "$vulnerable" = false ]; then
        DiagnosisResult="root 계정의 PATH 환경변수가 안전하게 설정되어 있습니다."
        Status="양호"
        append_to_csv "$DiagnosisResult" "$Status"
    fi
fi

cat $TMP1

echo ; echo

cat $CSV_FILE

echo "CSV report generated: $CSV_FILE"
echo ; echo
