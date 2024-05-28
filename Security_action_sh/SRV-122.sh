#!/bin/bash

# 결과 파일 초기화
TMP1="$(SCRIPTNAME).log"
> $TMP1

echo "UMASK 설정 점검" >> $TMP1
echo "=================" >> $TMP1

# 시스템 전체의 UMASK 설정 점검
current_umask=$(umask)
if [ "$current_umask" = "0022" ] || [ "$current_umask" < "0022" ]; then
    echo "OK: 시스템 전체 UMASK 설정이 022 또는 더 엄격함 ($current_umask)" >> $TMP1
else
    echo "WARN: 시스템 전체 UMASK 설정이 022보다 덜 엄격함 ($current_umask)" >> $TMP1
fi

# /etc/profile과 사용자 환경 설정 파일에서 UMASK 설정 점검
config_files=("/etc/profile" "/etc/bash.bashrc" "/etc/environment")
user_dirs=$(awk -F: '$7 ~ /^(\/bin\/bash|\/bin\/sh)$/ {print $6}' /etc/passwd)

for file in "${config_files[@]}" "/root/.bashrc" "/root/.profile"; do
    if [ -f "$file" ] && grep -q 'umask' "$file"; then
        umask_value=$(grep 'umask' "$file" | awk '{print $2}' | sed 's/[^0-9]*//g')
        if [ "$umask_value" = "0022" ] || [ "$umask_value" < "0022" ]; then
            echo "OK: $file 내 UMASK 설정이 적절함 ($umask_value)" >> $TMP1
        else
            echo "WARN: $file 내 UMASK 설정이 022보다 덜 엄격함 ($umask_value)" >> $TMP1
        fi
    fi
done

for dir in $user_dirs; do
    for file in ".bashrc" ".bash_profile" ".profile"; do
        if [ -f "$dir/$file" ] && grep -q 'umask' "$dir/$file"; then
            umask_value=$(grep 'umask' "$dir/$file" | awk '{print $2}' | sed 's/[^0-9]*//g')
            if [ "$umask_value" = "0022" ] || [ "$umask_value" < "0022" ]; then
                echo "OK: $dir/$file 내 UMASK 설정이 적절함 ($umask_value)" >> $TMP1
            else
                echo "WARN: $dir/$file 내 UMASK 설정이 022보다 덜 엄격함 ($umask_value)" >> $TMP1
            fi
        fi
    done
done

# 결과 파일 출력
cat $TMP1
echo
