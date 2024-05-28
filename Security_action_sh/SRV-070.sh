#!/bin/bash

# 패스워드 저장 방식 강화 스크립트
TMP1=$(basename "$0").log
> $TMP1

echo "패스워드 저장 방식 강화 시작..." >> $TMP1

# PAM 비밀번호 해싱 알고리즘 설정 파일
PAM_FILE="/etc/pam.d/common-password"

# 취약한 해싱 알고리즘(md5, des) 사용 여부 확인 및 강력한 알고리즘(예: SHA-512)으로 교체
if grep -Eq "md5|des" "$PAM_FILE"; then
    echo "취약한 패스워드 해싱 알고리즘을 강력한 알고리즘으로 교체합니다." >> $TMP1
    
    # MD5 및 DES 알고리즘을 SHA-512로 교체
    sed -i 's/md5/sha512/g' $PAM_FILE
    sed -i 's/des/sha512/g' $PAM_FILE

    # 변경 사항 확인
    if grep -Eq "sha512" "$PAM_FILE"; then
        echo "패스워드 저장에 강력한 해싱 알고리즘(SHA-512)이 적용되었습니다: $PAM_FILE" >> $TMP1
    else
        echo "패스워드 해싱 알고리즘 변경에 실패했습니다. 수동으로 확인이 필요합니다: $PAM_FILE" >> $TMP1
    fi
else
    echo "이미 강력한 패스워드 해싱 알고리즘이 사용 중입니다: $PAM_FILE" >> $TMP1
fi

cat "$TMP1"
echo ; echo
