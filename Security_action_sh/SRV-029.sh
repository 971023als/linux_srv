#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

echo "[SRV-029] SMB 세션 중단 관리 설정 조치" >> $TMP1

# SMB 설정 파일 경로
SMB_CONF_FILE="/etc/samba/smb.conf"

# 설정할 SMB 세션 중단 시간 (예: 15분)
DEADTIME=15

# deadtime 설정 확인 및 추가/수정
if grep -q "^[\t ]*deadtime" "$SMB_CONF_FILE"; then
    # deadtime 설정이 이미 존재하면, 값을 업데이트합니다.
    sed -i "s/^\([\t ]*deadtime\).*/\1 = $DEADTIME/" "$SMB_CONF_FILE"
    echo "조치: 기존 deadtime 설정을 $DEADTIME 분으로 업데이트하였습니다." >> $TMP1
else
    # deadtime 설정이 없는 경우, 파일 끝에 추가합니다.
    echo -e "\ndeadtime = $DEADTIME" >> "$SMB_CONF_FILE"
    echo "조치: deadtime 설정을 $DEADTIME 분으로 $SMB_CONF_FILE 파일에 추가하였습니다." >> $TMP1
fi

# SMB 서비스 재시작
systemctl restart smbd

echo "SMB 서비스가 재시작되었습니다." >> $TMP1

BAR

cat "$TMP1"

echo ; echo
