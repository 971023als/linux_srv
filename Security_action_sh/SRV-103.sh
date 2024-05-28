#!/bin/bash

# 결과 파일 정의
TMP1="$(SCRIPTNAME).log"
> $TMP1

echo "LAN Manager 인증 수준 미흡 여부 점검" >> $TMP1
echo "====================================" >> $TMP1

# smb.conf 파일의 위치를 정의합니다.
SMB_CONF="/etc/samba/smb.conf"

# smb.conf 파일이 존재하는지 확인합니다.
if [ -f "$SMB_CONF" ]; then
    # smb.conf에서 'lanman auth' 및 'ntlm auth' 설정을 확인합니다.
    LANMAN_AUTH=$(grep -i "^ *lanman auth" $SMB_CONF | awk '{print $NF}')
    NTLM_AUTH=$(grep -i "^ *ntlm auth" $SMB_CONF | awk '{print $NF}')

    # 설정에 따라 결과를 기록합니다.
    if [ "$LANMAN_AUTH" = "no" ] && ([ "$NTLM_AUTH" = "no" ] || [ -z "$NTLM_AUTH" ]); then
        echo "양호: LAN Manager 인증 수준이 적절하게 설정되어 있습니다." >> $TMP1
    else
        echo "취약: LAN Manager 인증 수준이 미흡하게 설정되어 있습니다." >> $TMP1
    fi
else
    echo "정보: Samba 서버 설정 파일($SMB_CONF)이 존재하지 않습니다." >> $TMP1
fi

# 결과 파일 출력
cat $TMP1
echo
