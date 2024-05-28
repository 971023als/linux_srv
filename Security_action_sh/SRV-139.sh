#!/bin/bash

# 결과 파일 초기화
TMP1="$(SCRIPTNAME).log"
> "$TMP1"

# 중요 시스템 자원 파일 목록
important_files=(
    "/etc/passwd"
    "/etc/shadow"
    "/etc/hosts"
    "/etc/xinetd.conf"
    "/etc/inetd.conf"
    "/etc/syslog.conf"
    "/etc/services"
    "/etc/ftpusers"
    "/etc/exports"
)

# 각 파일의 소유자 및 권한 검사
for file in "${important_files[@]}"; do
    if [ -f "$file" ]; then
        owner=$(stat -c %U "$file")
        permissions=$(stat -c %a "$file")

        # 소유자가 root인지 확인
        if [ "$owner" != "root" ]; then
            echo "WARN: $file 소유자가 root가 아닙니다." >> "$TMP1"
        else
            # 각 파일별 권한 기준에 따른 검사
            case "$file" in
                "/etc/passwd" | "/etc/hosts" | "/etc/services" | "/etc/exports")
                    if [ "$permissions" -le "644" ]; then
                        echo "OK: $file의 권한이 적절합니다." >> "$TMP1"
                    else
                        echo "WARN: $file의 권한이 644보다 큽니다." >> "$TMP1"
                    fi
                    ;;
                "/etc/shadow")
                    if [ "$permissions" -le "400" ]; then
                        echo "OK: $file의 권한이 적절합니다." >> "$TMP1"
                    else
                        echo "WARN: $file의 권한이 400보다 큽니다." >> "$TMP1"
                    fi
                    ;;
                "/etc/xinetd.conf" | "/etc/inetd.conf" | "/etc/syslog.conf" | "/etc/ftpusers")
                    if [ "$permissions" -le "640" ]; then
                        echo "OK: $file의 권한이 적절합니다." >> "$TMP1"
                    else
                        echo "WARN: $file의 권한이 640보다 큽니다." >> "$TMP1"
                    fi
                    ;;
                *)
                    echo "INFO: $file 파일에 대한 권한 검사가 설정되지 않았습니다." >> "$TMP1"
                    ;;
            esac
        fi
    else
        echo "INFO: $file 파일이 존재하지 않습니다." >> "$TMP1"
    fi
done

# 결과 파일 출력
cat "$TMP1"
