#!/bin/bash

# SSH 설정 파일 경로
SSH_CONFIG_FILE="/etc/ssh/sshd_config"

# 사용자로부터 허용할 사용자 이름 입력받기
read -p "허용할 사용자 이름을 공백으로 구분하여 입력하세요: " ALLOWED_USERS

# 현재 AllowUsers 설정 확인
if grep -q "^AllowUsers" $SSH_CONFIG_FILE; then
    # AllowUsers 설정이 이미 존재하면, 해당 줄을 업데이트
    sed -i "/^AllowUsers/c\AllowUsers $ALLOWED_USERS" $SSH_CONFIG_FILE
else
    # AllowUsers 설정이 존재하지 않으면, 파일 끝에 추가
    echo "AllowUsers $ALLOWED_USERS" >> $SSH_CONFIG_FILE
fi

# SSH 서비스 재시작
systemctl restart sshd

echo "SSH 로그인 설정이 업데이트되었습니다. 허용된 사용자: $ALLOWED_USERS"
