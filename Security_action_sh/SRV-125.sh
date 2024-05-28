#!/bin/bash

# 결과 파일 초기화
TMP1="$(SCRIPTNAME).log"
> $TMP1

echo "화면보호기 설정 점검" >> $TMP1
echo "===================" >> $TMP1

# GNOME 데스크톱 환경 점검
if command -v gsettings > /dev/null; then
  if gsettings get org.gnome.desktop.screensaver lock-enabled | grep -q 'true'; then
    echo "OK: GNOME에서 화면보호기가 설정되어 있습니다." >> $TMP1
  else
    echo "WARN: GNOME에서 화면보호기가 설정되어 있지 않습니다." >> $TMP1
  fi
else
  echo "INFO: GNOME 화면보호기 도구가 설치되어 있지 않습니다." >> $TMP1
fi

# KDE Plasma 점검
if command -v qdbus > /dev/null; then
  if qdbus org.freedesktop.ScreenSaver /ScreenSaver org.freedesktop.ScreenSaver.GetActive | grep -q 'true'; then
    echo "OK: KDE에서 화면보호기가 설정되어 있습니다." >> $TMP1
  else
    echo "WARN: KDE에서 화면보호기가 설정되어 있지 않습니다." >> $TMP1
  fi
else
  echo "INFO: KDE 화면보호기 도구가 설치되어 있지 않습니다." >> $TMP1
fi

# Xfce 점검
if command -v xfconf-query > /dev/null; then
  if xfconf-query -c xfce4-screensaver -p /saver/enabled | grep -q 'true'; then
    echo "OK: Xfce에서 화면보호기가 설정되어 있습니다." >> $TMP1
  else
    echo "WARN: Xfce에서 화면보호기가 설정되어 있지 않습니다." >> $TMP1
  fi
else
  echo "INFO: Xfce 화면보호기 도구가 설치되어 있지 않습니다." >> $TMP1
fi

# Cinnamon 점검
if command -v gsettings > /dev/null; then
  if gsettings get org.cinnamon.desktop.screensaver lock-enabled | grep -q 'true'; then
    echo "OK: Cinnamon에서 화면보호기가 설정되어 있습니다." >> $TMP1
  else
    echo "WARN: Cinnamon에서 화면보호기가 설정되어 있지 않습니다." >> $TMP1
  fi
else
  echo "INFO: Cinnamon 화면보호기 도구가 설치되어 있지 않습니다." >> $TMP1
fi

# 결과 파일 출력
cat $TMP1
echo
