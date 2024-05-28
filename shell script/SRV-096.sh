#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $CSV_FILE ]; then
    echo "Category,Code,Risk Level,Diagnosis Item,Service,DiagnosisResult,Status" > $CSV_FILE
fi

BAR

CATEGORY="사용자 환경 보안"
CODE="SRV-096"
RISK_LEVEL="중"
DIAGNOSIS_ITEM="사용자 환경 파일 소유자 또는 권한 설정이 미흡함"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
CODE [SRV-096] 사용자 환경파일의 소유자 또는 권한 설정 미흡

[양호]: 사용자 환경 파일의 소유자가 해당 사용자이고, 권한이 적절하게 설정된 경우
[취약]: 사용자 환경 파일의 소유자가 해당 사용자가 아니거나, 권한이 부적절하게 설정된 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,사용자 환경,$result,$status" >> $CSV_FILE
}

# 사용자 홈 디렉터리 및 소유자 정보 추출 함수
extract_user_homedirectory_info() {
    user_homedirectory_path=($(awk -F: '$7!="/bin/false" && $7!="/sbin/nologin" && $6!="" {print $6}' /etc/passwd))
    user_homedirectory_owner_name=($(awk -F: '$7!="/bin/false" && $7!="/sbin/nologin" && $6!="" {print $1}' /etc/passwd))

    for dir in /home/*; do
        user_homedirectory_owner_name+=($(basename "$dir"))
    done
}

# 사용자 홈 디렉터리 및 소유자 정보 추출 실행
extract_user_homedirectory_info

# 시작 파일 검사 시작
start_files=(".profile" ".cshrc" ".login" ".kshrc" ".bash_profile" ".bashrc" ".bash_login")
for i in "${!user_homedirectory_path[@]}"; do
    result_status="양호"
    for file in "${start_files[@]}"; do
        filepath="${user_homedirectory_path[$i]}/$file"
        if [ -f "$filepath" ]; then
            file_owner=$(ls -l $filepath | awk '{print $3}')
            other_permission=$(ls -l $filepath | awk '{print substr($1,9,1)}')
            if [[ $file_owner != "root" && $file_owner != "${user_homedirectory_owner_name[$i]}" ]] || [[ $other_permission == "w" ]]; then
                if [[ $other_permission == "w" ]]; then
                    append_to_csv "${user_homedirectory_path[$i]} 홈 디렉터리 내 $file 환경 변수 파일에 다른 사용자(other)의 쓰기(w) 권한이 부여 되어 있습니다." "취약"
                else
                    append_to_csv "${user_homedirectory_path[$i]} 홈 디렉터리 내 $file 환경 변수 파일의 소유자(owner)가 root 또는 해당 계정이 아닙니다." "취약"
                fi
                result_status="취약"
                break 2  # 해당 사용자에 대한 검사 중단 및 다음 사용자로 넘어감
            fi
        fi
    done
    if [[ $result_status == "양호" ]]; then
        append_to_csv "${user_homedirectory_path[$i]} 홈 디렉터리 내 검사된 모든 시작 파일이 적절한 소유자를 가지며, 다른 사용자(other)의 쓰기(w) 권한이 없습니다." "양호"
    fi
done

check_service_files() {
    local service_file=$1
    local vulnerable=0
    # /etc/hosts.equiv 파일 검사
    if [ -f /etc/hosts.equiv ]; then
        local etc_hostsequiv_permissions=$(stat -c "%a" /etc/hosts.equiv)
        local etc_hostsequiv_owner=$(stat -c "%U" /etc/hosts.equiv)
        if [[ "$etc_hostsequiv_owner" != "root" ]]; then
            append_to_csv "/etc/hosts.equiv 파일의 소유자가 root가 아닙니다." "취약"
            vulnerable=1
        fi
        if [[ "$etc_hostsequiv_permissions" -gt 600 ]]; then
            append_to_csv "/etc/hosts.equiv 파일의 권한이 600을 초과합니다." "취약"
            vulnerable=1
        fi
        if grep -qE '^\s*+' /etc/hosts.equiv && [[ $vulnerable -eq 0 ]]; then
            append_to_csv "/etc/hosts.equiv 파일에 '+' 문자가 포함되어 있습니다." "취약"
            vulnerable=1
        fi
    fi

    # 사용자 홈 디렉터리 내 .rhosts 파일 검사
    for dir in "${user_homedirectory_path[@]}"; do
        if [ -f "$dir/.rhosts" ]; then
            local rhosts_permissions=$(stat -c "%a" "$dir/.rhosts")
            local rhosts_owner=$(stat -c "%U" "$dir/.rhosts")
            if [[ "$rhosts_permissions" -gt 600 ]]; then
                append_to_csv "$dir/.rhosts 파일의 권한이 600을 초과합니다." "취약"
                vulnerable=1
            fi
            if ! [[ "$rhosts_owner" == "root" || "${user_homedirectory_owner_name[@]}" =~ "$rhosts_owner" ]]; then
                append_to_csv "$dir/.rhosts 파일의 소유자가 유효하지 않습니다." "취약"
                vulnerable=1
            fi
            if grep -qE '^\s*\+' "$dir/.rhosts" && [[ $vulnerable -eq 0 ]]; then
                append_to_csv "$dir/.rhosts 파일에 '+' 문자가 포함되어 있습니다." "취약"
                vulnerable=1
            fi
        fi
    done

    # 양호한 결과에 대한 처리
    if [[ $vulnerable -eq 0 ]]; then
        append_to_csv "r 계열 서비스 설정이 양호합니다." "양호"
    fi
}

# r 계열 서비스 명령어 배열 생성
r_command=("rsh" "rlogin" "rexec" "shell" "login" "exec")

# 취약한 설정을 발견했을 경우의 처리 로직 추가
if [ -d /etc/xinetd.d ]; then
    for cmd in "${r_command[@]}"; do
        if [ -f "/etc/xinetd.d/$cmd" ] && ! grep -qE '^\s*disable\s*=\s*yes' "/etc/xinetd.d/$cmd"; then
            # 취약한 서비스 발견
            check_service_files "/etc/xinetd.d/$cmd"
            append_to_csv "$cmd 서비스가 활성화되어 있습니다." "취약"
            break
        fi
    done
elif [ -f /etc/inetd.conf ]; then
    for cmd in "${r_command[@]}"; do
        if grep -qE "^\s*$cmd" /etc/inetd.conf; then
            # 취약한 서비스 발견
            check_service_files "/etc/inetd.conf"
            append_to_csv "$cmd 서비스가 활성화되어 있습니다." "취약"
            break
        fi
    done
else
    append_to_csv "r 계열 서비스가 비활성화되어 있습니다." "양호"
fi

# 결과 파일 출력
cat $TMP1

echo "CSV report generated: $CSV_FILE"
echo ; echo
