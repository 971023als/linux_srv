#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="output.csv"
if [ ! -f $CSV_FILE ]; then
    echo "Category,Code,Risk Level,Diagnosis Item,DiagnosisResult,Status" > $CSV_FILE
fi

BAR

CATEGORY="보안 소프트웨어"
CODE="SRV-129"
RISK_LEVEL="높음"
DIAGNOSIS_ITEM="백신 프로그램 설치 여부"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 백신 프로그램이 설치되어 있는 경우
[취약]: 백신 프로그램이 설치되어 있지 않은 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local category=$1
    local code=$2
    local risk_level=$3
    local diagnosis_item=$4
    local service=$5
    local diagnosis_result=$6
    local status=$7
    echo "$category,$code,$risk_level,$diagnosis_item,$diagnosis_result,$status" >> $CSV_FILE
}

# 일반적으로 사용되는 백신 프로그램의 설치 여부를 확인합니다
antivirus_programs=("clamav" "avast" "avg" "avira" "eset")

installed_antivirus=()

for antivirus in "${antivirus_programs[@]}"; do
    if command -v $antivirus &> /dev/null; then
        installed_antivirus+=("$antivirus")
    fi
done

# 설치된 백신 프로그램이 있는지 확인합니다
if [ ${#installed_antivirus[@]} -eq 0 ]; then
    diagnosis_result="설치된 백신 프로그램이 없습니다."
    WARN "$diagnosis_result"
    append_to_csv "$CATEGORY" "$CODE" "$RISK_LEVEL" "$DIAGNOSIS_ITEM" "$diagnosis_result" "취약"
else
    diagnosis_result="설치된 백신 프로그램: ${installed_antivirus[*]}"
    OK "$diagnosis_result"
    append_to_csv "$CATEGORY" "$CODE" "$RISK_LEVEL" "$DIAGNOSIS_ITEM"  "$diagnosis_result" "양호"
fi

cat $TMP1

echo ; echo

cat $CSV_FILE

echo "CSV report generated: $CSV_FILE"
echo ; echo
