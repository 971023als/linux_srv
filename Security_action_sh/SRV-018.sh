#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

echo "[SRV-018] 불필요한 하드디스크 기본 공유 비활성화 조치" >> $TMP1

# NFS 공유 비활성화
NFS_EXPORTS_FILE="/etc/exports"
if [ -f "$NFS_EXPORTS_FILE" ]; then
    sed -i '/^\s*\/.*$/d' "$NFS_EXPORTS_FILE"
    echo "NFS 서비스에서 불필요한 공유를 비활성화하였습니다: $NFS_EXPORTS_FILE" >> $TMP1
else
    echo "NFS 서비스 설정 파일($NFS_EXPORTS_FILE)을 찾을 수 없습니다." >> $TMP1
fi

# SMB/CIFS 공유 비활성화
SMB_CONF_FILE="/etc/samba/smb.conf"
if [ -f "$SMB_CONF_FILE" ]; then
    sed -i '/^\s*\[.*\]$/,/^\s*path\s*=/ s/^/#/' "$SMB_CONF_FILE"
    echo "SMB/CIFS 서비스에서 불필요한 공유를 비활성화하였습니다: $SMB_CONF_FILE" >> $TMP1
else
    echo "SMB/CIFS 서비스 설정 파일($SMB_CONF_FILE)을 찾을 수 없습니다." >> $TMP1
fi

BAR

cat "$TMP1"

echo
