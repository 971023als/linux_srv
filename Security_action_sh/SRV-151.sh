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
$settingName = "Network access: Allow anonymous SID/Name translation"
$desiredSetting = "Disabled"

# 보안 설정 가져오기
$securitySettings = secedit /export /cfg c:\temp\secpol.cfg

# 설정 파일 수정
(Get-Content -path c:\temp\secpol.cfg) |
Foreach-Object {$_ -replace "SeDenyNetworkLogonRight = .*$", "SeDenyNetworkLogonRight = *S-1-1-0"} |
Set-Content -Path c:\temp\secpol.cfg

# 수정된 설정 적용
secedit /configure /db secedit.sdb /cfg c:\temp\secpol.cfg /areas SECURITYPOLICY

# 임시 파일 제거
Remove-Item -Path c:\temp\secpol.cfg

Write-Host "익명 SID/이름 변환을 허용하지 않도록 설정되었습니다."

fi

cat $result

echo ; echo
