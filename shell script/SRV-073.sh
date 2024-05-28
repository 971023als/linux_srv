#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="$(basename "$0" .sh).csv"
echo "Category,Code,Risk Level,Diagnosis Item,DiagnosisResult,Status" > $CSV_FILE

BAR

CATEGORY="네트워크 보안"
CODE="SRV-073"
RISK_LEVEL="높음"
DIAGNOSIS_ITEM="관리자 그룹 내 사용자 멤버쉽 검사"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 관리자 그룹에 불필요한 사용자가 없는 경우
[취약]: 관리자 그룹에 불필요한 사용자가 존재하는 경우
EOF

BAR

# 관리자 그룹 이름을 정의합니다 (예: sudo, wheel)
admin_group="sudo"

# 관리자 그룹의 멤버 확인
admin_members=$(getent group "$admin_group" | cut -d: -f4)

# 예상되지 않은 사용자가 관리자 그룹에 있는지 확인
# 여기서는 예시로 'testuser'를 사용하지만, 실제 환경에 맞게 수정 필요
unnecessary_user="testuser"

if [[ $admin_members == *"$unnecessary_user"* ]]; then
    DiagnosisResult="관리자 그룹($admin_group)에 불필요한 사용자($unnecessary_user)가 포함되어 있습니다."
    Status="취약"
    echo "WARN: $DiagnosisResult" >> $TMP1
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,$DiagnosisResult,$Status" >> $CSV_FILE
else
    DiagnosisResult="관리자 그룹($admin_group)에 불필요한 사용자가 없습니다."
    Status="양호"
    echo "OK: $DiagnosisResult" >> $TMP1
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,$DiagnosisResult,$Status" >> $CSV_FILE
fi

cat $TMP1

echo "CSV report generated: $CSV_FILE"
echo ; echo
cat $CSV_FILE
