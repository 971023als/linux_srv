#!/bin/bash

# 결과 파일 초기화
TMP1="$(SCRIPTNAME).log"
> $TMP1

echo "계정 잠금 임계값 설정 점검" >> $TMP1
echo "=========================" >> $TMP1

# 계정 잠금 임계값 설정 파일 및 모듈
deny_settings_files=("/etc/pam.d/system-auth" "/etc/pam.d/password-auth")
deny_modules=("pam_tally2.so" "pam_faillock.so")

# 설정 파일 및 모듈 검사
for file in "${deny_settings_files[@]}"; do
    if [ -f "$file" ]; then
        for module in "${deny_modules[@]}"; do
            setting=$(grep -vE '^#|^\s*' "$file" | grep -i "$module" | grep -i 'deny=')
            if [[ -n "$setting" ]]; then
                # deny 값을 추출하여 검사
                deny_value=$(echo "$setting" | grep -oP 'deny=\K\d+')
                if [[ "$deny_value" -lt 11 ]]; then
                    echo "OK: $file 에서 $module 의 계정 잠금 임계값이 적절하게 설정됨 (값: $deny_value)" >> $TMP1
                else
                    echo "WARN: $file 에서 $module 의 계정 잠금 임계값이 11회 이상으로 설정됨 (값: $deny_value)" >> $TMP1
                fi
            else
                echo "WARN: $file 에서 $module 의 계정 잠금 임계값 설정이 발견되지 않음" >> $TMP1
            fi
        done
    else
        echo "INFO: $file 파일이 존재하지 않음" >> $TMP1
    fi
done

# 결과 파일 출력
cat $TMP1
echo
