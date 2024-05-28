#!/bin/bash

. function.sh

TMP1=$(basename "$0").log
> $TMP1

BAR

echo "[SRV-021] FTP 서비스 접근 제어 설정 조치" >> $TMP1

# FTP 서비스 구성 파일의 소유자 및 권한 조정
ftpusers_files=("/etc/ftpusers" "/etc/pure-ftpd/ftpusers" "/etc/wu-ftpd/ftpusers" "/etc/vsftpd/ftpusers" "/etc/proftpd/ftpusers" "/etc/ftpd/ftpusers" "/etc/vsftpd.ftpusers" "/etc/vsftpd.user_list" "/etc/vsftpd/user_list")
for file in "${ftpusers_files[@]}"; do
    if [ -f "$file" ]; then
        # 파일 소유자를 root로 변경
        chown root "$file"
        # 파일 권한을 640으로 설정
        chmod 640 "$file"
        echo "조치: $file 파일의 소유자를 root로 변경하고, 권한을 640으로 설정하였습니다." >> $TMP1
    fi
done

if [ ${#ftpusers_files[@]} -eq 0 ]; then
    WARN "ftp 접근 제어 파일이 없습니다." >> $TMP1
else
    OK "모든 ftpusers 파일에 대한 조치 완료." >> $TMP1
fi

BAR

cat $TMP1

echo ; echo
