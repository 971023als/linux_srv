#!/bin/bash

# SSH 접속을 특정 그룹에게만 제한하는 스크립트
# 이 스크립트는 /etc/ssh/sshd_config 파일을 수정합니다.

# 허용할 그룹을 지정하세요.
ALLOWED_GROUP="sshusers"

# sshd_config 파일의 위치를 찾습니다.
SSHD_CONFIG="/etc/ssh/sshd_config"

# 파일 백업
cp $SSHD_CONFIG "${SSHD_CONFIG}.bak"

# AllowGroups 설정을 확인하고 추가합니다.
if grep -q "^AllowGroups" $SSHD_CONFIG; then
    echo "AllowGroups 설정이 이미 존재합니다. 설정을 업데이트합니다."
    sed -i "/^AllowGroups/c\AllowGroups $ALLOWED_GROUP" $SSHD_CONFIG
else
    echo "AllowGroups 설정을 추가합니다."
    echo "AllowGroups $ALLOWED_GROUP" >> $SSHD_CONFIG
fi

# sshd 서비스를 재시작하여 변경사항을 적용합니다.
systemctl restart sshd

echo "SSH 접속이 $ALLOWED_GROUP 그룹에게만 제한되도록 설정되었습니다."
