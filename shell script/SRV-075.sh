#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="$(basename "$0" .sh).csv"
if [ ! -f $CSV_FILE ]; then
    echo "Category,Code,Risk Level,Diagnosis Item,DiagnosisResult,Status" > $CSV_FILE
fi

BAR

CATEGORY="계정 보안"
CODE="SRV-075"
RISK_LEVEL="중"
DIAGNOSIS_ITEM="비밀번호 정책 감사"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 암호 정책이 강력하게 설정되어 있는 경우
[취약]: 암호 정책이 약하게 설정되어 있는 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,$result,$status" >> $CSV_FILE
}

# Variables initialization
file_exists_count=0
minlen_file_exists_count=0
no_settings_in_minlen_file=0
mininput_file_exists_count=0
no_settings_in_mininput_file=0
input_options=("lcredit" "ucredit" "dcredit" "ocredit")
input_modules=("pam_pwquality.so" "pam_cracklib.so" "pam_unix.so")

# Password policy check function
check_password_policy() {
    local file_path=$1
    local setting_type=$2
    local setting_name=$3
    local min_value=$4
    local message=$5

    if [ -f "$file_path" ]; then
        ((file_exists_count++))
        local setting_count
        local setting_value
        case $setting_type in
            "minlen")
                ((minlen_file_exists_count++))
                setting_count=$(grep -vE '^#|^\s#' $file_path | grep -i $setting_name | wc -l)
                if [ $setting_count -gt 0 ]; then
                    setting_value=$(grep -vE '^#|^\s#' $file_path | grep -i $setting_name | awk '{print $2}')
                    if [ $setting_value -lt $min_value ]; then
                        append_to_csv "$file_path 파일에 $message" "취약"
                    fi
                else
                    ((no_settings_in_minlen_file++))
                fi
                ;;
            "mininput")
                ((mininput_file_exists_count++))
                setting_count=$(grep -vE '^#|^\s#' $file_path | grep -i $setting_name | wc -l)
                if [ $setting_count -gt 0 ]; then
                    setting_value=$(grep -vE '^#|^\s#' $file_path | grep -i $setting_name | awk '{print $2}')
                    if [ $setting_value -lt $min_value ]; then
                        append_to_csv "$file_path 파일에 $message" "취약"
                    fi
                else
                    ((no_settings_in_mininput_file++))
                fi
                ;;
        esac
    fi
}

# Check password policy settings
check_password_policy "/etc/login.defs" "minlen" "PASS_MIN_LEN" 8 "패스워드 최소 길이가 8 미만으로 설정되어 있습니다."
for file in "/etc/pam.d/system-auth" "/etc/pam.d/password-auth"; do
    for module in "${input_modules[@]}"; do
        check_password_policy "$file" "minlen" "minlen" 8 "패스워드 최소 길이가 8 미만으로 설정되어 있습니다."
        for option in "${input_options[@]}"; do
            check_password_policy "$file" "mininput" "$option" 1 "패스워드의 영문, 숫자, 특수문자의 최소 입력이 1 미만으로 설정되어 있습니다."
        done
    done
done
check_password_policy "/etc/security/pwquality.conf" "minlen" "minlen" 8 "패스워드 최소 길이가 8 미만으로 설정되어 있습니다."
for option in "${input_options[@]}"; do
    check_password_policy "/etc/security/pwquality.conf" "mininput" "$option" 1 "패스워드의 영문, 숫자, 특수문자의 최소 입력이 1 미만으로 설정되어 있습니다."
done

# Check password maximum usage period
if [ -f /etc/login.defs ]; then
    etc_logindefs_maxdays_count=$(grep -vE '^#|^\s#' /etc/login.defs | grep -i 'PASS_MAX_DAYS' | awk '{print $2}' | wc -l)
    if [ $etc_logindefs_maxdays_count -gt 0 ]; then
        etc_logindefs_maxdays_value=$(grep -vE '^#|^\s#' /etc/login.defs | grep -i 'PASS_MAX_DAYS' | awk '{print $2}')
        if [ $etc_logindefs_maxdays_value -gt 90 ]; then
            append_to_csv "/etc/login.defs 파일에 패스워드 최대 사용 기간이 91일 이상으로 설정되어 있습니다." "취약"
        else
            append_to_csv "패스워드 최대 사용 기간이 적절하게 설정되어 있습니다." "양호"
        fi
    else
        append_to_csv "/etc/login.defs 파일에 패스워드 최대 사용 기간이 설정되어 있지 않습니다." "취약"
    fi
else
    append_to_csv "/etc/login.defs 파일이 없습니다." "취약"
fi

# Check password minimum usage period
if [ -f /etc/login.defs ]; then
    etc_logindefs_mindays_count=$(grep -vE '^#|^\s#' /etc/login.defs | grep -i 'PASS_MIN_DAYS' | awk '{print $2}' | wc -l)
    if [ $etc_logindefs_mindays_count -gt 0 ]; then
        etc_logindefs_mindays_value=$(grep -vE '^#|^\s#' /etc/login.defs | grep -i 'PASS_MIN_DAYS' | awk '{print $2}')
        if [ $etc_logindefs_mindays_value -lt 1 ]; then
            append_to_csv "/etc/login.defs 파일에 패스워드 최소 사용 기간이 1일 미만으로 설정되어 있습니다." "취약"
        else
            append_to_csv "패스워드 최소 사용 기간이 적절하게 설정되어 있습니다." "양호"
        fi
    else
        append_to_csv "/etc/login.defs 파일에 패스워드 최소 사용 기간이 설정되어 있지 않습니다." "취약"
    fi
else
    append_to_csv "/etc/login.defs 파일이 없습니다." "취약"
fi

# Check for shadow password usage
if [ $(awk -F : '$2!="x"' /etc/passwd | wc -l) -gt 0 ]; then
    append_to_csv "쉐도우 패스워드를 사용하고 있지 않습니다." "취약"
else
    append_to_csv "쉐도우 패스워드를 사용하고 있습니다." "양호"
fi

cat $TMP1

echo "CSV report generated: $CSV_FILE"
echo ; echo
cat $CSV_FILE
