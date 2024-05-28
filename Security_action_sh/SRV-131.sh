#!/bin/bash

# 초기 설정
TMP1="$(SCRIPTNAME).log"
> $TMP1

echo "SU 명령 사용가능 그룹 제한 점검" >> $TMP1
echo "=================================" >> $TMP1

# /etc/pam.d/su 파일 점검
if [ -f /etc/pam.d/su ]; then
    # pam_wheel.so 모듈 존재 여부 확인
    if grep -q "auth.*required.*pam_wheel.so use_uid" /etc/pam.d/su; then
        echo "OK: /etc/pam.d/su 파일에 pam_wheel.so 모듈이 적절하게 설정되어 있습니다." >> $TMP1
    else
        echo "WARN: /etc/pam.d/su 파일에 pam_wheel.so 모듈 설정이 미비합니다." >> $TMP1
    fi
else
    echo "WARN: /etc/pam.d/su 파일이 존재하지 않습니다." >> $TMP1
fi

# su 실행 파일 권한 점검
su_path=$(which su)
if [ -n "$su_path" ]; then
    su_permissions=$(stat -c "%A" $su_path)
    # su 실행 파일이 그룹과 다른 사용자에 의해 실행될 수 없도록 설정되어 있는지 확인
    if [[ $su_permissions == -* ]]; then
        echo "OK: $su_path 실행 파일의 권한이 적절하게 설정되어 있습니다. (권한: $su_permissions)" >> $TMP1
    else
        echo "WARN: $su_path 실행 파일의 권한 설정이 미비합니다. (권한: $su_permissions)" >> $TMP1
    fi
else
    echo "INFO: su 실행 파일이 시스템에 존재하지 않습니다." >> $TMP1
fi

# 결과 파일 출력
cat $TMP1
echo
