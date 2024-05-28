#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

echo "[SRV-031] 계정 목록 및 네트워크 공유 이름 노출 조치" >> $TMP1

# SMB 설정 파일 경로
SMB_CONF_FILE="/etc/samba/smb.conf"

# 공유 목록 및 계정 정보 노출 방지 설정
# 'enum shares = no'와 'enum users = no' 설정을 smb.conf 파일에 추가합니다.
# 이 설정은 smb.conf 파일 내 적절한 섹션(예: [global])에 위치해야 합니다.

# [global] 섹션 확인 및 설정 추가
if grep -q "^\[global\]" "$SMB_CONF_FILE"; then
    # enum shares와 enum users 설정이 이미 있는지 확인하고, 없으면 추가
    if ! grep -q "^[\t ]*enum shares" "$SMB_CONF_FILE"; then
        sed -i "/^\[global\]/a enum shares = no" "$SMB_CONF_FILE"
    fi
    if ! grep -q "^[\t ]*enum users" "$SMB_CONF_FILE"; then
        sed -i "/^\[global\]/a enum users = no" "$SMB_CONF_FILE"
    fi
else
    # [global] 섹션이 없는 경우, 파일 상단에 추가
    echo -e "[global]\nenum shares = no\nenum users = no\n" >> "$SMB_CONF_FILE"
fi

echo "SMB 서비스에서 계정 목록 및 네트워크 공유 이름 노출 방지 설정을 추가하였습니다." >> $TMP1

# SMB 서비스 재시작
systemctl restart smbd

echo "SMB 서비스가 재시작되었습니다." >> $TMP1

BAR

cat "$TMP1"

echo ; echo
