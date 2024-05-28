#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

echo "[SRV-060] 웹 서비스 기본 계정 정보 변경 조치" >> $TMP1

# 웹 서비스의 기본 계정 설정 파일 예시 (실제 환경에 맞게 조정하세요)
CONFIG_FILE="/etc/web_service/config"

# 기본 계정 정보 변경
# 주의: 실제 비밀번호 변경은 해당 웹 서비스의 관리 도구나 명령어를 통해 수행해야 할 수 있습니다.
# 아래는 설정 파일 내에서 직접 변경하는 방식의 예시입니다.
if [ -f "$CONFIG_FILE" ]; then
    # 'admin' 사용자명과 'password' 비밀번호를 새로운 값으로 변경합니다.
    # 실제 사용할 새로운 사용자명과 비밀번호로 대체하세요.
    sed -i 's/username=admin/username=new_admin/g' "$CONFIG_FILE"
    sed -i 's/password=password/password=new_password/g' "$CONFIG_FILE"
    echo "웹 서비스의 기본 계정(아이디 또는 비밀번호)을 변경했습니다: $CONFIG_FILE" >> $TMP1
else
    echo "지정된 설정 파일($CONFIG_FILE)이 존재하지 않습니다." >> $TMP1
fi

BAR

cat "$TMP1"

echo ; echo
