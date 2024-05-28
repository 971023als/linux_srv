#!/bin/bash

# 결과 파일 초기화
TMP1="$(SCRIPTNAME).log"
> $TMP1

echo "root 계정의 PATH 환경변수 설정 점검" >> $TMP1
echo "=====================================" >> $TMP1

# root 계정의 PATH 환경변수 검사
root_path_issue_detected=0
if echo $PATH | grep -Eq '\.:' || echo $PATH | grep -Eq '::'; then
    echo "WARN: root 계정의 PATH 환경 변수 내에 안전하지 않은 경로('.') 또는 빈 경로('::')가 포함되어 있습니다." >> $TMP1
    root_path_issue_detected=1
fi

# /etc 디렉터리 내 설정 파일의 PATH 변수 점검
etc_files=("/etc/profile" "/etc/bash.bashrc" "/root/.bashrc" "/root/.bash_profile")
for file in "${etc_files[@]}"; do
    if [ -f "$file" ] && grep -Eq 'PATH=.*(\.::|::|\.:)' "$file"; then
        echo "WARN: 파일 $file 내에 안전하지 않은 PATH 설정이 포함되어 있습니다." >> $TMP1
        root_path_issue_detected=1
    fi
done

# 결과 출력
if [ $root_path_issue_detected -eq 0 ]; then
    echo "OK: root 계정의 PATH 환경변수 설정이 안전합니다." >> $TMP1
else
    echo "조치가 필요합니다: root 계정의 PATH 환경변수 설정에서 안전하지 않은 경로를 제거하세요." >> $TMP1
fi

# 결과 파일 출력
cat $TMP1
echo
