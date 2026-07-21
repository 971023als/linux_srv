#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

CODE [SRV-151] 익명 SID/이름 변환 허용

cat << EOF >> $result
[양호]: 익명 SID/이름 변환을 허용하지 않는 경우
[취약]: 익명 SID/이름 변환을 허용하는 경우
EOF

BAR

# PowerShell 스크립트로 익명 SID/이름 변환 허용하지 않도록 설정
# (Windows 전용 항목 - Linux에서는 N/A)
settingName="Network access: Allow anonymous SID/Name translation"

INFO "SRV-151: 익명 SID/이름 변환 허용 - Linux 환경에서는 해당 없음 (N/A)" >> $result

cat $result

echo ; echo
