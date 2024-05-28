#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

echo "[SRV-025] 취약한 hosts.equiv 또는 .rhosts 설정 존재 조치" >> $TMP1

# hosts.equiv 파일의 존재 및 설정을 확인하고 조치합니다.
if [ -f /etc/hosts.equiv ]; then
    # '+' 문자를 포함하는 라인 삭제
    sed -i '/^+/d' /etc/hosts.equiv
    # 파일 소유자와 권한 조정
    chown root:root /etc/hosts.equiv
    chmod 600 /etc/hosts.equiv
    echo "조치: /etc/hosts.equiv 파일이 안전하게 구성되었습니다." >> $TMP1
else
    echo "조치: /etc/hosts.equiv 파일이 존재하지 않습니다." >> $TMP1
fi

# 사용자 홈 디렉터리 내 .rhosts 파일을 확인하고 조치합니다.
user_homedirs=$(awk -F: '$6 ~ /^\/home\// {print $6}' /etc/passwd)
for dir in $user_homedirs; do
    if [ -f "$dir/.rhosts" ]; then
        # 파일 삭제 또는 '+' 문자를 포함하는 라인 삭제
        # rm "$dir/.rhosts"
        sed -i '/^+/d' "$dir/.rhosts"
        # 파일 소유자와 권한 조정
        chown root:root "$dir/.rhosts"
        chmod 600 "$dir/.rhosts"
        echo "조치: $dir/.rhosts 파일이 안전하게 구성되었습니다." >> $TMP1
    else
        echo "조치: $dir 디렉터리 내 .rhosts 파일이 존재하지 않습니다." >> $TMP1
    fi
done

BAR

cat "$TMP1"

echo ; echo
