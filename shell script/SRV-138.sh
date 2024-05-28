#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="output.csv"
if [ ! -f $CSV_FILE ]; then
    echo "Category,Code,Risk Level,Diagnosis Item,Service,DiagnosisResult,Status" > $CSV_FILE
fi

BAR

CATEGORY="데이터 보안"
CODE="SRV-138"
RISK_LEVEL="높음"
DIAGNOSIS_ITEM="백업 및 복구 권한 설정"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 백업 및 복구 권한이 적절히 설정된 경우
[취약]: 백업 및 복구 권한이 적절히 설정되지 않은 경우
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

# 백업 관련 디렉토리 및 파일 권한 확인
backup_dirs=("/path/to/backup/dir1" "/path/to/backup/dir2") # 백업 디렉토리 예시
diagnosis_result=""
status="양호"

for dir in "${backup_dirs[@]}"; do
    if [ -d "$dir" ]; then
        permissions=$(stat -c %a "$dir")
        owner=$(stat -c %U "$dir")
        # 백업 디렉토리 소유자 및 권한 확인
        if [[ "$owner" == "backup_user" && "$permissions" -le 700 ]]; then
            OK "$dir 은 적절한 권한($permissions) 및 소유자($owner)를 가집니다." >> $TMP1
            diagnosis_result="$dir 은 적절한 권한($permissions) 및 소유자($owner)를 가집니다."
        else
            WARN "$dir 은 부적절한 권한($permissions) 또는 소유자($owner)를 가집니다." >> $TMP1
            diagnosis_result="$dir 은 부적절한 권한($permissions) 또는 소유자($owner)를 가집니다."
            status="취약"
        fi
    else
        INFO "$dir 디렉토리가 존재하지 않습니다." >> $TMP1
        diagnosis_result="$dir 디렉토리가 존재하지 않습니다."
    fi
done

# Append final result to CSV
append_to_csv "$CATEGORY" "$CODE" "$RISK_LEVEL" "$DIAGNOSIS_ITEM" "$diagnosis_result" "$status"

cat $TMP1

echo "CSV report generated: $CSV_FILE"
echo ; echo
