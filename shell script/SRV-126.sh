#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE="output.csv"
if [ ! -f $CSV_FILE ]; then
    echo "Category,Code,Risk Level,Diagnosis Item,Service,DiagnosisResult,Status" > $CSV_FILE
fi

BAR

CATEGORY="시스템 구성"
CODE="SRV-126"
RISK_LEVEL="높음"
DIAGNOSIS_ITEM="자동 로그온 방지 설정 검사"
SERVICE="System Configuration"
DiagnosisResult=""
Status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 자동 로그온이 비활성화된 경우
[취약]: 자동 로그온이 활성화된 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,$SERVICE,$result,$status" >> $CSV_FILE
}

# GDM (GNOME Display Manager) 설정 확인
if [ -f /etc/gdm3/custom.conf ]; then
    if grep -q "AutomaticLoginEnable=false" /etc/gdm3/custom.conf; then
        append_to_csv "GDM에서 자동 로그온이 비활성화되어 있습니다." "양호"
    else
        append_to_csv "GDM에서 자동 로그온이 활성화되어 있습니다." "취약"
    fi
else
    append_to_csv "GDM 설정 파일이 존재하지 않습니다." "정보"
fi

# LightDM 설정 확인
if [ -f /etc/lightdm/lightdm.conf ]; then
    if grep -q "autologin-user=" /etc/lightdm/lightdm.conf; then
        append_to_csv "LightDM에서 자동 로그온이 설정되어 있습니다." "취약"
    else
        append_to_csv "LightDM에서 자동 로그온이 비활성화되어 있습니다." "양호"
    fi
else
    append_to_csv "LightDM 설정 파일이 존재하지 않습니다." "정보"
fi

cat $TMP1

echo ; echo

cat $CSV_FILE

echo "CSV report generated: $CSV_FILE"
echo ; echo
