#!/bin/bash

# 패스워드 정책 강화를 위한 설정 파일 수정
PAM_PWQUALITY_CONF="/etc/security/pwquality.conf"
LOGIN_DEFS="/etc/login.defs"
PAM_SYSTEM_AUTH="/etc/pam.d/system-auth"
PAM_PASSWORD_AUTH="/etc/pam.d/password-auth"

# pwquality.conf 설정
if [ -f "$PAM_PWQUALITY_CONF" ]; then
    echo "Updating $PAM_PWQUALITY_CONF for password quality requirements..."
    sed -i '/^minlen =/d' "$PAM_PWQUALITY_CONF"
    echo "minlen = 12" >> "$PAM_PWQUALITY_CONF"

    sed -i '/^dcredit =/d' "$PAM_PWQUALITY_CONF"
    echo "dcredit = -1" >> "$PAM_PWQUALITY_CONF"

    sed -i '/^ucredit =/d' "$PAM_PWQUALITY_CONF"
    echo "ucredit = -1" >> "$PAM_PWQUALITY_CONF"

    sed -i '/^lcredit =/d' "$PAM_PWQUALITY_CONF"
    echo "lcredit = -1" >> "$PAM_PWQUALITY_CONF"

    sed -i '/^ocredit =/d' "$PAM_PWQUALITY_CONF"
    echo "ocredit = -1" >> "$PAM_PWQUALITY_CONF"
else
    echo "$PAM_PWQUALITY_CONF not found, skipping..."
fi

# login.defs 설정
if [ -f "$LOGIN_DEFS" ]; then
    echo "Updating $LOGIN_DEFS for password aging requirements..."
    sed -i '/^PASS_MAX_DAYS/c\PASS_MAX_DAYS   90' "$LOGIN_DEFS"
    sed -i '/^PASS_MIN_DAYS/c\PASS_MIN_DAYS   1' "$LOGIN_DEFS"
    sed -i '/^PASS_WARN_AGE/c\PASS_WARN_AGE   7' "$LOGIN_DEFS"
else
    echo "$LOGIN_DEFS not found, skipping..."
fi

# system-auth 및 password-auth 설정
for FILE in "$PAM_SYSTEM_AUTH" "$PAM_PASSWORD_AUTH"; do
    if [ -f "$FILE" ]; then
        echo "Updating $FILE for password quality module..."
        if ! grep -q "pam_pwquality.so" "$FILE"; then
            sed -i '/^password    requisite     pam_pwquality.so/a password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=' "$FILE"
        fi
    else
        echo "$FILE not found, skipping..."
    fi
done

echo "Password policy update complete."
