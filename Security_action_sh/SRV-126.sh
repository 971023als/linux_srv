#!/bin/bash

# 결과 파일 초기화
TMP1="$(SCRIPTNAME).log"
> $TMP1

echo "자동 로그온 방지 설정 점검" >> $TMP1
echo "=========================" >> $TMP1

# GDM (GNOME Display Manager) 설정 확인
if [ -f /etc/gdm3/custom.conf ]; then
    if grep -q "^AutomaticLoginEnable=false" /etc/gdm3/custom.conf; then
        echo "OK: GDM에서 자동 로그온이 비활성화되어 있습니다." >> $TMP1
    else
        echo "WARN: GDM에서 자동 로그온이 활성화되어 있습니다." >> $TMP1
    fi
else
    echo "INFO: GDM 설정 파일이 존재하지 않습니다." >> $TMP1
fi

# LightDM 설정 확인
if [ -f /etc/lightdm/lightdm.conf ]; then
    if grep -q "^autologin-user=" /etc/lightdm/lightdm.conf; then
        echo "WARN: LightDM에서 자동 로그온이 설정되어 있습니다." >> $TMP1
    else
        echo "OK: LightDM에서 자동 로그온이 비활성화되어 있습니다." >> $TMP1
    fi
else
    echo "INFO: LightDM 설정 파일이 존재하지 않습니다." >> $TMP1
fi

# 결과 파일 출력
cat $TMP1
echo
