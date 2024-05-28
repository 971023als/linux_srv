#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
CATEGORY="시스템 보안"
CODE="SRV-122"
RISK_LEVEL="중"
DIAGNOSIS_ITEM="UMASK 설정 검사"
DiagnosisResult=""
Status=""

BAR

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 시스템 전체 UMASK 설정이 022 또는 더 엄격한 경우
[취약]: 시스템 전체 UMASK 설정이 022보다 덜 엄격한 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,$result,$status" >> $OUTPUT_CSV
}

# Check current UMASK value
umask_value=$(umask)
if [ ${umask_value:2:1} -lt 2 ]; then
    append_to_csv "그룹 사용자(group)에 대한 umask 값이 2 이상으로 설정되지 않았습니다." "취약"
    exit 0
elif [ ${umask_value:3:1} -lt 2 ]; then
    append_to_csv "다른 사용자(other)에 대한 umask 값이 2 이상으로 설정되지 않았습니다." "취약"
    exit 0
fi

# Check UMASK settings in /etc/profile
if [ -f /etc/profile ]; then
    etc_profile_umask_values=$(grep -vE '^#|^\s#' /etc/profile | grep -i 'umask' | grep -vE 'if|\`' | awk -F'=' '{print $2}' | tr -d ' ')
    for umask_value in $etc_profile_umask_values; do
        if [ ${#umask_value} -eq 2 ]; then
            if [ ${umask_value:0:1} -lt 2 ] || [ ${umask_value:1:1} -lt 2 ]; then
                append_to_csv "/etc/profile 파일에 umask 값이 022 이상으로 설정되지 않았습니다." "취약"
                exit 0
            fi
        elif [ ${#umask_value} -eq 4 ]; then
            if [ ${umask_value:2:1} -lt 2 ] || [ ${umask_value:3:1} -lt 2 ]; then
                append_to_csv "/etc/profile 파일에 umask 값이 0022 이상으로 설정되지 않았습니다." "취약"
                exit 0
            fi
        elif [ ${#umask_value} -eq 3 ]; then
            if [ ${umask_value:1:1} -lt 2 ] || [ ${umask_value:2:1} -lt 2 ]; then
                append_to_csv "/etc/profile 파일에 umask 값이 022 이상으로 설정되지 않았습니다." "취약"
                exit 0
            fi
        elif [ ${#umask_value} -eq 1 ]; then
            append_to_csv "/etc/profile 파일에 umask 값이 0022 이상으로 설정되지 않았습니다." "취약"
            exit 0
        else
            append_to_csv "/etc/profile 파일에 설정된 umask 값이 보안 설정에 부합하지 않습니다." "취약"
            exit 0
        fi
    done
fi

# Check other configuration files
umask_settings_files=("/etc/bashrc" "/etc/csh.login" "/etc/csh.cshrc")
for file in "${umask_settings_files[@]}"; do
    if [ -f "$file" ]; then
        umask_values=$(grep -vE '^#|^\s#' "$file" | grep -i 'umask' | awk '{print $2}' | tr -d ' ')
        for umask_value in $umask_values; do
            if [ ${#umask_value} -eq 2 ]; then
                if [ ${umask_value:0:1} -lt 2 ] || [ ${umask_value:1:1} -lt 2 ]; then
                    append_to_csv "$file 파일에 umask 값이 022 이상으로 설정되지 않았습니다." "취약"
                    exit 0
                fi
            elif [ ${#umask_value} -eq 4 ]; then
                if [ ${umask_value:2:1} -lt 2 ] || [ ${umask_value:3:1} -lt 2 ]; then
                    append_to_csv "$file 파일에 umask 값이 0022 이상으로 설정되지 않았습니다." "취약"
                    exit 0
                fi
            elif [ ${#umask_value} -eq 3 ]; then
                if [ ${umask_value:1:1} -lt 2 ] || [ ${umask_value:2:1} -lt 2 ]; then
                    append_to_csv "$file 파일에 umask 값이 022 이상으로 설정되지 않았습니다." "취약"
                    exit 0
                fi
            elif [ ${#umask_value} -eq 1 ]; then
                append_to_csv "$file 파일에 umask 값이 0022 이상으로 설정되지 않았습니다." "취약"
                exit 0
            else
                append_to_csv "$file 파일에 설정된 umask 값이 보안 설정에 부합하지 않습니다." "취약"
                exit 0
            fi
        done
    fi
done

# Check UMASK settings in user home directories
user_homedirectory_path=($(awk -F: '$7!="/bin/false" && $7!="/sbin/nologin" && $6!="" {print $6}' /etc/passwd | uniq))
user_homedirectory_path+=("/home/*")
umask_settings_files=(".cshrc" ".profile" ".login" ".bashrc" ".kshrc")
for home_dir in "${user_homedirectory_path[@]}"; do
    for file in "${umask_settings_files[@]}"; do
        if [ -f "$home_dir/$file" ]; then
            umask_values=$(grep -vE '^#|^\s#' "$home_dir/$file" | grep -i 'umask' | awk '{print $2}' | tr -d ' ')
            for umask_value in $umask_values; do
                if [ ${#umask_value} -eq 2 ]; then
                    if [ ${umask_value:0:1} -lt 2 ] || [ ${umask_value:1:1} -lt 2 ]; then
                        append_to_csv "$home_dir/$file 파일에 umask 값이 022 이상으로 설정되지 않았습니다." "취약"
                        exit 0
                    fi
                elif [ ${#umask_value} -eq 4 ]; then
                    if [ ${umask_value:2:1} -lt 2 ] || [ ${umask_value:3:1} -lt 2 ]; then
                        append_to_csv "$home_dir/$file 파일에 umask 값이 0022 이상으로 설정되지 않았습니다." "취약"
                        exit 0
                    fi
                elif [ ${#umask_value} -eq 3 ]; then
                    if [ ${umask_value:1:1} -lt 2 ] || [ ${umask_value:2:1} -lt 2 ]; then
                        append_to_csv "$home_dir/$file 파일에 umask 값이 022 이상으로 설정되지 않았습니다." "취약"
                        exit 0
                    fi
                elif [ ${#umask_value} -eq 1 ]; then
                    append_to_csv "$home_dir/$file 파일에 umask 값이 0022 이상으로 설정되지 않았습니다." "취약"
                    exit 0
                else
                    append_to_csv "$home_dir/$file 파일에 설정된 umask 값이 보안 설정에 부합하지 않습니다." "취약"
                    exit 0
                fi
            done
        fi
    done
done

append_to_csv "시스템 전체 UMASK 설정이 022 또는 더 엄격합니다." "양호"

cat $TMP1

echo ; echo

cat $OUTPUT_CSV

echo "CSV report generated: $OUTPUT_CSV"
echo ; echo
