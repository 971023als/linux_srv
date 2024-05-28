#!/bin/bash

# 결과 파일 초기화
TMP1="$(SCRIPTNAME).log"
> $TMP1

echo "보안 감사 실패 시 시스템 종료 설정 상태 점검" >> $TMP1
echo "============================================" >> $TMP1

# auditd.conf 파일 경로
auditd_conf="/etc/audit/auditd.conf"

# auditd 설정 확인
space_left_action=$(grep -i "^space_left_action" $auditd_conf | awk '{print $3}')
admin_space_left_action=$(grep -i "^admin_space_left_action" $auditd_conf | awk '{print $3}')

# 설정이 적절한지 확인
if [ "$space_left_action" != "email" ] || [ "$admin_space_left_action" != "halt" ]; then
  echo "보안 감사 실패 시 시스템이 즉시 종료되도록 수정합니다." >> $TMP1
  
  # space_left_action을 email로 설정
  sed -i 's/^space_left_action.*/space_left_action = email/' $auditd_conf
  
  # admin_space_left_action을 halt로 설정
  sed -i 's/^admin_space_left_action.*/admin_space_left_action = halt/' $auditd_conf
  
  echo "수정 완료: 보안 감사 로그 공간이 부족할 경우 시스템이 즉시 종료되도록 설정됨." >> $TMP1
else
  echo "보안 감사 실패 시 시스템이 즉시 종료되도록 이미 적절하게 설정됨." >> $TMP1
fi

# auditd 서비스 재시작
systemctl restart auditd
echo "auditd 서비스 재시작 완료." >> $TMP1

# 결과 출력
cat $TMP1
echo
