#!/bin/bash

. function.sh

TMP1=$(basename "$0").log
> $TMP1

BAR

echo "[SRV-013] Anonymous 계정의 FTP 서비스 접속 제한 조치" >> $TMP1

# proftpd.conf 파일에서 Anonymous 접속 설정 변경
proftpd_files=$(find / -name 'proftpd.conf' -type f 2>/dev/null)
for file in $proftpd_files; do
    if grep -q '<Anonymous' "$file"; then
        sed -i '/<Anonymous/,/<\/Anonymous>/d' "$file"
        echo "조치: $file 파일에서 Anonymous 섹션을 삭제하였습니다." >> $TMP1
    fi
done

# vsftpd.conf 파일에서 anonymous_enable YES를 NO로 변경
vsftpd_files=$(find / -name 'vsftpd.conf' -type f 2>/dev/null)
for file in $vsftpd_files; do
    if grep -q '^anonymous_enable=YES' "$file"; then
        sed -i 's/^anonymous_enable=YES/anonymous_enable=NO/g' "$file"
        echo "조치: $file 파일에서 anonymous_enable를 NO로 변경하였습니다." >> $TMP1
    elif ! grep -q '^anonymous_enable=' "$file"; then
        echo "anonymous_enable=NO" >> "$file"
        echo "조치: $file 파일에 anonymous_enable=NO를 추가하였습니다." >> $TMP1
    fi
done

if [ -z "$proftpd_files" ] && [ -z "$vsftpd_files" ]; then
    echo "WARN: FTP 설정 파일이 발견되지 않았습니다. FTP 서버가 설치되어 있는지 확인하세요." >> $TMP1
else
    echo "OK: Anonymous FTP 접속 차단 조치 완료." >> $TMP1
fi

BAR

cat $TMP1
echo ; echo
