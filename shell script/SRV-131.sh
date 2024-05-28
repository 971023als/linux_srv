#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="output.csv"
if [ ! -f $CSV_FILE ]; then
    echo "Category,Code,Risk Level,Diagnosis Item,DiagnosisResult,Status" > $CSV_FILE
fi

BAR

CATEGORY="시스템 관리"
CODE="SRV-131"
RISK_LEVEL="높음"
DIAGNOSIS_ITEM="SU 명령 사용 가능 그룹 제한"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: SU 명령을 특정 그룹에만 허용한 경우
[취약]: SU 명령을 모든 사용자가 사용할 수 있는 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local category=$1
    local code=$2
    local risk_level=$3
    local diagnosis_item=$4
    local diagnosis_result=$5
    local status=$6
    echo "$category,$code,$risk_level,$diagnosis_item,$diagnosis_result,$status" >> $CSV_FILE
}

# Check if libpam is installed
rpm_libpam_count=$(rpm -qa 2>/dev/null | grep '^libpam' | wc -l)
dnf_libpam_count=$(dnf list installed 2>/dev/null | grep -i '^libpam' | wc -l)

if [ $rpm_libpam_count -gt 0 ] && [ $dnf_libpam_count -gt 0 ]; then
    # Check for pam_rootok.so in /etc/pam.d/su
    etc_pamd_su_rootokso_count=$(grep -vE '^#|^\s#' /etc/pam.d/su | grep 'pam_rootok.so' | wc -l)
    if [ $etc_pamd_su_rootokso_count -gt 0 ]; then
        # Check for pam_wheel.so in /etc/pam.d/su
        etc_pamd_su_wheelso_count=$(grep -vE '^#|^\s#' /etc/pam.d/su | grep 'pam_wheel.so' | wc -l)
        if [ $etc_pamd_su_wheelso_count -eq 0 ]; then
            diagnosis_result="/etc/pam.d/su 파일에 pam_wheel.so 모듈이 없습니다."
            WARN "$diagnosis_result" >> $TMP1
            append_to_csv "$CATEGORY" "$CODE" "$RISK_LEVEL" "$DIAGNOSIS_ITEM" "$diagnosis_result" "취약"
            exit 0
        fi
    else
        diagnosis_result="/etc/pam.d/su 파일에서 pam_rootok.so 모듈이 없습니다."
        WARN "$diagnosis_result" >> $TMP1
        append_to_csv "$CATEGORY" "$CODE" "$RISK_LEVEL" "$DIAGNOSIS_ITEM" "$diagnosis_result" "취약"
        exit 0
    fi
else
    su_executables=("/bin/su" "/usr/bin/su")
    if [ $(which su 2>/dev/null | wc -l) -gt 0 ]; then
        su_executables+=($(which su 2>/dev/null))
    fi
    for su_executable in "${su_executables[@]}"; do
        if [ -f "$su_executable" ]; then
            su_group_permission=$(stat -c "%A" "$su_executable" | cut -c 5)
            if [[ $su_group_permission != "-" ]]; then
                su_other_permission=$(stat -c "%A" "$su_executable" | cut -c 8)
                if [[ $su_other_permission != "-" ]]; then
                    diagnosis_result="${su_executable} 실행 파일의 다른 사용자(other)에 대한 권한 취약합니다."
                    WARN "$diagnosis_result" >> $TMP1
                    append_to_csv "$CATEGORY" "$CODE" "$RISK_LEVEL" "$DIAGNOSIS_ITEM" "$diagnosis_result" "취약"
                    exit 0
                fi
            else
                diagnosis_result="${su_executable} 실행 파일의 그룹 사용자(group)에 대한 권한 취약합니다."
                WARN "$diagnosis_result" >> $TMP1
                append_to_csv "$CATEGORY" "$CODE" "$RISK_LEVEL" "$DIAGNOSIS_ITEM" "$diagnosis_result" "취약"
                exit 0
            fi
        fi
    done
fi

diagnosis_result="SU 명령이 특정 그룹에만 허용되어 있습니다."
OK "$diagnosis_result" >> $TMP1
append_to_csv "$CATEGORY" "$CODE" "$RISK_LEVEL" "$DIAGNOSIS_ITEM" "$diagnosis_result" "양호"

cat $TMP1

echo "CSV report generated: $CSV_FILE"
echo ; echo
