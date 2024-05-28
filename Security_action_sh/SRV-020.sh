#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

echo "[SRV-020] 공유에 대한 접근 통제 조치" >> $TMP1

# NFS 공유 접근 통제 강화
NFS_EXPORTS_FILE="/etc/exports"
if [ -f "$NFS_EXPORTS_FILE" ]; then
    # 'everyone' 또는 'public' 설정 제거 (예시)
    sed -i '/everyone/d' "$NFS_EXPORTS_FILE"
    sed -i '/public/d' "$NFS_EXPORTS_FILE"
    echo "NFS 서비스에서 공유 접근 통제를 강화하였습니다: $NFS_EXPORTS_FILE" >> $TMP1
else
    echo "NFS 서비스 설정 파일($NFS_EXPORTS_FILE)을 찾을 수 없습니다." >> $TMP1
fi

# SMB/CIFS 공유 접근 통제 강화
SMB_CONF_FILE="/etc/samba/smb.conf"
if [ -f "$SMB_CONF_FILE" ]; then
    # 'guest ok = yes' 설정을 'no'로 변경 (예시)
    sed -i 's/guest ok = yes/guest ok = no/g' "$SMB_CONF_FILE"
    # 'public = yes' 설정을 'no'로 변경 (예시)
    sed -i 's/public = yes/public = no/g' "$SMB_CONF_FILE"
    echo "SMB/CIFS 서비스에서 공유 접근 통제를 강화하였습니다: $SMB_CONF_FILE" >> $TMP1
else
    echo "SMB/CIFS 서비스 설정 파일($SMB_CONF_FILE)을 찾을 수 없습니다." >> $TMP1
fi

BAR

cat "$TMP1"

echo
