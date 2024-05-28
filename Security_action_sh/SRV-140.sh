#!/bin/bash

# 결과 파일 초기화
TMP1="$(SCRIPTNAME).log"
> "$TMP1"

# GNOME 환경 설정 확인을 위한 dconf 경로
dconf_path="/org/gnome/desktop/media-handling"

# dconf 도구 설치 및 GNOME 환경 확인
if command -v dconf >/dev/null; then
    # 이동식 미디어 자동 마운트 및 열기 설정 확인
    media_automount=$(dconf read "${dconf_path}/automount")
    media_automount_open=$(dconf read "${dconf_path}/automount-open")
    
    # 이동식 미디어 설정이 적절히 비활성화되어 있는지 검사
    if [[ "$media_automount" == "false" && "$media_automount_open" == "false" ]]; then
        echo "OK: 이동식 미디어의 자동 마운트 및 열기가 비활성화되어 있습니다." >> "$TMP1"
    else
        echo "WARN: 이동식 미디어의 자동 마운트 또는 열기가 활성화되어 있습니다." >> "$TMP1"
    fi
else
    echo "INFO: dconf 도구가 설치되어 있지 않거나 GNOME 환경이 아닙니다." >> "$TMP1"
fi

# 결과 출력
cat "$TMP1"
