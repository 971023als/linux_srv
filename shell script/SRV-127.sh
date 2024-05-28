#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="output.csv"
if [ ! -f $CSV_FILE ]; then
    echo "Category,Code,Risk Level,Diagnosis Item,DiagnosisResult,Status" > $CSV_FILE
fi

BAR

CATEGORY="계정 관리"
CODE="SRV-127"
RISK_LEVEL="높음"
DIAGNOSIS_ITEM="계정 잠금 임계값 설정 검사"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 계정 잠금 임계값이 적절하게 설정된 경우
[취약]: 계정 잠금 임계값이 적절하게 설정되지 않은 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,$result,$status" >> $CSV_FILE
}

file_exists_count=0
deny_file_exists_count=0
no_settings_in_deny_file=0
deny_modules=("pam_tally2.so" "pam_faillock.so")

# /etc/pam.d/system-auth, /etc/pam.d/password-auth 파일 내 계정 잠금 임계값 설정 확인함
deny_settings_files=("/etc/pam.d/system-auth" "/etc/pam.d/password-auth")
for deny_settings_file in "${deny_settings_files[@]}"; do
    if [ -f "$deny_settings_file" ]; then
        ((file_exists_count++))
        for deny_module in "${deny_modules[@]}"; do
            ((deny_file_exists_count++))
            deny_settings_file_deny_count=$(grep -vE '^#|^\s#' "$deny_settings_file" | grep -i "$deny_module" | grep -i 'deny' | wc -l)
            if [ $deny_settings_file_deny_count -gt 0 ]; then
                deny_settings_file_deny_value=$(grep -vE '^#|^\s#' "$deny_settings_file" | grep -i "$deny_module" | grep -i 'deny' | awk -F 'deny=' '{print $2}' | awk '{print $1}')
                if [ "$deny_settings_file_deny_value" -gt 10 ]; then
                    append_to_csv "$deny_settings_file 파일에 계정 잠금 임계값이 11회 이상으로 설정되어 있습니다." "취약"
                    exit 0
                fi
            else
                ((no_settings_in_deny_file++))
            fi
        done
    fi
done

if [ $file_exists_count -eq 0 ]; then
    append_to_csv "계정 잠금 임계값을 설정하는 파일이 없습니다." "취약"
    exit 0
elif [ $deny_file_exists_count -eq $no_settings_in_deny_file ]; then
    append_to_csv "계정 잠금 임계값을 설정한 파일이 없습니다." "취약"
    exit 0
fi

append_to_csv "계정 잠금 임계값이 적절하게 설정되어 있습니다." "양호"

cat $TMP1

echo ; echo

cat $CSV_FILE

echo "CSV report generated: $CSV_FILE"
echo ; echo
