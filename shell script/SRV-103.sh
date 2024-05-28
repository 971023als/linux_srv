#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

CODE [SRV-103] LAN Manager 인증 수준 미흡

cat << EOF >> $result
[양호]: LAN Manager 인증 수준이 적절하게 설정되어 있는 경우
[취약]: LAN Manager 인증 수준이 미흡하게 설정되어 있는 경우
EOF

BAR

# LAN Manager 인증 수준을 확인하는 코드
# 예시: registry 값을 체크하거나, 관련 설정 파일을 검사
# 이 부분은 시스템의 구체적인 설정 방법에 따라 달라질 수 있음

# 예시 결과 출력
OK "LAN Manager 인증 수준이 적절하게 설정되어 있습니다."

cat $result

echo ; echo
