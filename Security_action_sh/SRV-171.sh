#!/bin/bash

# vsftpd 설정 파일
vsftpd_config="/etc/vsftpd.conf"

# ProFTPD 설정 파일
proftpd_config="/etc/proftpd/proftpd.conf"

# vsftpd 설정 확인 및 수정
if [ -f "$vsftpd_config" ]; then
    if ! grep -q '^ftpd_banner=' "$vsftpd_config"; then
        echo "vsftpd 버전 정보 노출 제한 설정을 적용합니다."
        echo 'ftpd_banner=Welcome to FTP service.' >> "$vsftpd_config"
        systemctl restart vsftpd
    else
        echo "vsftpd는 이미 버전 정보 노출이 제한된 상태입니다."
    fi
else
    echo "vsftpd 설정 파일이 존재하지 않습니다."
fi

# ProFTPD 설정 확인 및 수정
if [ -f "$proftpd_config" ]; then
    if ! grep -q 'ServerIdent on "FTP Server ready."' "$proftpd_config"; then
        echo "ProFTPD 버전 정보 노출 제한 설정을 적용합니다."
        sed -i '/ServerIdent on/c\ServerIdent on "FTP Server ready."' "$proftpd_config"
        systemctl restart proftpd
    else
        echo "ProFTPD는 이미 버전 정보 노출이 제한된 상태입니다."
    fi
else
    echo "ProFTPD 설정 파일이 존재하지 않습니다."
fi
