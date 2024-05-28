#!/bin/bash

# 함수 라이브러리를 로드합니다.
. function.sh

# 임시 로그 파일을 초기화합니다.
TMP1=$(SCRIPTNAME).log
> $TMP1

# 로그 분리를 위한 함수
BAR() {
    echo "==================================================" >> $TMP1
}

BAR
echo "존재하지 않는 소유자 및 그룹 권한을 가진 파일 또는 디렉터리 검사" >> $TMP1
BAR

# 존재하지 않는 사용자나 그룹의 파일 및 디렉터리 검사
orphans=$(find / \( -nouser -or -nogroup \) -print 2>/dev/null)
if [ -n "$orphans" ]; then
    WARN "소유자 또는 그룹이 존재하지 않는 파일 및 디렉터리가 있습니다." >> $TMP1
    echo "$orphans" >> $TMP1
else
    OK "소유자 또는 그룹이 존재하지 않는 파일 또는 디렉터리가 없습니다." >> $TMP1
fi

BAR
echo "/dev 디렉터리 내 적절하지 않은 파일 검사" >> $TMP1
BAR

# /dev 디렉터리 내에 적절하지 않은 파일 검사
if find /dev -type f -exec test ! -c {} \; -print 2>/dev/null | grep -q .; then
    WARN "/dev 디렉터리에 적절하지 않은 파일이 존재합니다." >> $TMP1
else
    OK "/dev 디렉터리에 적절하지 않은 파일이 존재하지 않습니다." >> $TMP1
fi

BAR
echo "사용자 홈 디렉터리 설정 검사" >> $TMP1
BAR

# 홈 디렉터리가 없거나, 루트(/)로 설정된 계정 검사
while IFS=: read -r user _ _ _ _ home _; do
    if [ "$home" == "" ] || [ "$home" == "/" -a "$user" != "root" ]; then
        WARN "계정 $user 의 홈 디렉터리가 적절하지 않게 설정되었습니다: $home" >> $TMP1
    fi
done < /etc/passwd

OK "모든 사용자의 홈 디렉터리가 적절히 설정되었습니다." >> $TMP1

# 결과 출력
cat $TMP1
echo
