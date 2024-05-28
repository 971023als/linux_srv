#!/bin/bash

# 필요한 함수 라이브러리 로드
. function.sh

# 결과 파일 초기화
TMP1="$(SCRIPTNAME).log"
> $TMP1

# 결과 파일에 기본 정보 추가
echo "FTP 서비스 디렉터리 접근권한 설정 점검" >> $TMP1
echo "==============================================" >> $TMP1

# FTP 서비스 실행 여부 확인
ftp_service_active=false
if systemctl is-active --quiet vsftpd || systemctl is-active --quiet proftpd; then
    ftp_service_active=true
    echo "FTP 서비스가 실행 중입니다." >> $TMP1
else
    echo "FTP 서비스가 비활성화되어 있습니다." >> $TMP1
fi

# FTP 서비스 디렉터리의 접근 권한 설정 점검
if $ftp_service_active; then
    ftp_directories=("/var/ftp" "/srv/ftp") # FTP 서비스 디렉터리 경로 추가
    for dir in "${ftp_directories[@]}"; do
        if [ -d "$dir" ]; then
            permissions=$(stat -c "%a" "$dir")
            owner=$(stat -c "%U" "$dir")
            if [ "$permissions" -le "755" ] && [ "$owner" == "root" ]; then
                echo "[$dir] 디렉터리의 접근 권한이 적절하게 설정되어 있습니다. (권한: $permissions, 소유자: $owner)" >> $TMP1
            else
                echo "[$dir] 디렉터리의 접근 권한이 부적절합니다. (권한: $permissions, 소유자: $owner)" >> $TMP1
            fi
        else
            echo "[$dir] 디렉터리가 존재하지 않습니다." >> $TMP1
        fi
    done
else
    echo "FTP 서비스가 비활성화되어 있으므로 디렉터리 접근 권한 설정 점검을 건너뜁니다." >> $TMP1
fi

# 결과 파일 출력
cat $TMP1
echo
