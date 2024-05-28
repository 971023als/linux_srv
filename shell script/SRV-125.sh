#!/bin/bash

. function.sh

# Initialize CSV file
CSV_FILE=$(SCRIPTNAME).csv
echo "Category,Code,Risk Level,Diagnosis Item,DiagnosisResult,Status" > $CSV_FILE

BAR

CATEGORY="사용자 인터페이스 보안"
CODE="SRV-125"
RISK_LEVEL="중"
DIAGNOSIS_ITEM="화면보호기 설정 검사"
DiagnosisResult=""
Status=""

cat << EOF >> $TMP1
[양호]: 화면보호기가 설정되어 있는 경우
[취약]: 화면보호기가 설정되어 있지 않은 경우
EOF

BAR

# Function to append results to CSV file
append_to_csv() {
    local result=$1
    local status=$2
    echo "$CATEGORY,$CODE,$RISK_LEVEL,$DIAGNOSIS_ITEM,$result,$status" >> $CSV_FILE
}

# GNOME 데스크톱 환경
if command -v gsettings > /dev/null; then
  if gsettings get org.gnome.desktop.screensaver lock-enabled | grep -q 'true'; then
    append_to_csv "GNOME에서 화면보호기가 설정되어 있습니다." "양호"
  else
    append_to_csv "GNOME에서 화면보호기가 설정되어 있지 않습니다." "취약"
  fi
else
  append_to_csv "GNOME 화면보호기 도구가 설치되어 있지 않습니다." "정보"
fi

# KDE Plasma
if command -v qdbus > /dev/null; then
  if qdbus org.freedesktop.ScreenSaver /ScreenSaver org.freedesktop.ScreenSaver.GetActive | grep -q 'true'; then
    append_to_csv "KDE에서 화면보호기가 설정되어 있습니다." "양호"
  else
    append_to_csv "KDE에서 화면보호기가 설정되어 있지 않습니다." "취약"
  fi
else
  append_to_csv "KDE 화면보호기 도구가 설치되어 있지 않습니다." "정보"
fi

# Xfce
if command -v xfconf-query > /dev/null; then
  if xfconf-query -c xfce4-screensaver -p /saver/enabled | grep -q 'true'; then
    append_to_csv "Xfce에서 화면보호기가 설정되어 있습니다." "양호"
  else
    append_to_csv "Xfce에서 화면보호기가 설정되어 있지 않습니다." "취약"
  fi
else
  append_to_csv "Xfce 화면보호기 도구가 설치되어 있지 않습니다." "정보"
fi

# Cinnamon
if command -v gsettings > /dev/null; then
  if gsettings get org.cinnamon.desktop.screensaver lock-enabled | grep -q 'true'; then
    append_to_csv "Cinnamon에서 화면보호기가 설정되어 있습니다." "양호"
  else
    append_to_csv "Cinnamon에서 화면보호기가 설정되어 있지 않습니다." "취약"
  fi
else
  append_to_csv "Cinnamon 화면보호기 도구가 설치되어 있지 않습니다." "정보"
fi

cat $TMP1

echo "CSV report generated: $CSV_FILE"
echo ; echo
