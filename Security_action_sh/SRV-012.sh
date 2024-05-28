#!/bin/bash

. function.sh

# 결과 파일 초기화
TMP1=$(basename "$0").log
> $TMP1

BAR

echo "[SRV-012] .netrc 파일 내 중요 정보 노출 조치" >> $TMP1

# 시스템 전체에서 .netrc 파일 찾기 및 조치
netrc_files=$(find / -name ".netrc" 2>/dev/null)

if [ -z "$netrc_files" ]; then
    echo "OK: 시스템에 .netrc 파일이 존재하지 않습니다." >> $TMP1
else
    echo "WARN: 다음 위치에 .netrc 파일이 존재합니다. 파일을 삭제합니다: $netrc_files" >> $TMP1
    for file in $netrc_files; do
        # .netrc 파일 삭제
        rm -f $file
        if [ $? -eq 0 ]; then
            echo "DELETED: $file 파일이 삭제되었습니다." >> $TMP1
        else
            echo "ERROR: $file 파일 삭제에 실패했습니다. 수동 조치가 필요합니다." >> $TMP1
        fi
    done
fi

BAR

cat $TMP1
echo ; echo
