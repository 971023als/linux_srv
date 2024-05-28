#!/bin/bash

# 비밀번호 정책 설정 조치 스크립트
TMP1=$(SCRIPTNAME).log
> $TMP1

echo "비밀번호 관리정책 설정 조치 시작..." >> $TMP1

# PAM 비밀번호 정책 설정
PAM_PWQUALITY_CONF="/etc/security/pwquality.conf"
PAM_SYSTEM_AUTH="/etc/pam.d/system-auth"

# pwquality.conf 설정 조정
if [ -f "$PAM_PWQUALITY_CONF" ]; then
    echo "Updating pwquality.conf settings..." >> $TMP1
    sed -i '/^minlen/d' $PAM_PWQUALITY_CONF
    echo "minlen = 12" >> $PAM_PWQUALITY_CONF  # 최소 길이 설정
    sed -i '/^dcredit/d' $PAM_PWQUALITY_CONF
    echo "dcredit = -1" >> $PAM_PWQUALITY_CONF  # 최소 하나의 숫자 필요
    sed -i '/^ucredit/d' $PAM_PWQUALITY_CONF
    echo "ucredit = -1" >> $PAM_PWQUALITY_CONF  # 최소 하나의 대문자 필요
    sed -i '/^lcredit/d' $PAM_PWQUALITY_CONF
    echo "lcredit = -1" >> $PAM_PWQUALITY_CONF  # 최소 하나의 소문자 필요
    sed -i '/^ocredit/d' $PAM_PWQUALITY_CONF
    echo "ocredit = -1" >> $PAM_PWQUALITY_CONF  # 최소 하나의 특수 문자 필요
else
    echo "$PAM_PWQUALITY_CONF 파일이 존재하지 않습니다." >> $TMP1
fi

# system-auth 설정 조정
if [ -f "$PAM_SYSTEM_AUTH" ]; then
    echo "Updating system-auth settings..." >> $TMP1
    if ! grep -q "pam_pwquality.so" $PAM_SYSTEM_AUTH; then
        echo "password requisite pam_pwquality.so try_first_pass retry=3" >> $PAM_SYSTEM_AUTH
    fi
else
    echo "$PAM_SYSTEM_AUTH 파일이 존재하지 않습니다." >> $TMP1
fi

# 로그인 정책 설정
LOGIN_DEFS="/etc/login.defs"
if [ -f "$LOGIN_DEFS" ]; then
    echo "Updating login.defs settings..." >> $TMP1
    sed -i '/^PASS_MAX_DAYS/d' $LOGIN_DEFS
    echo "PASS_MAX_DAYS   90" >> $LOGIN_DEFS  # 패스워드 최대 사용 기간
    sed -i '/^PASS_MIN_DAYS/d' $LOGIN_DEFS
    echo "PASS_MIN_DAYS   1" >> $LOGIN_DEFS  # 패스워드 최소 사용 기간
    sed -i '/^PASS_WARN_AGE/d' $LOGIN_DEFS
    echo "PASS_WARN_AGE   7" >> $LOGIN_DEFS  # 패스워드 만료 경고 기간
else
    echo "$LOGIN_DEFS 파일이 존재하지 않습니다." >> $TMP1
fi

echo "비밀번호 관리정책 설정 조치 완료." >> $TMP1
cat "$TMP1"
echo ; echo
