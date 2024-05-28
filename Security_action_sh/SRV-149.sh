#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

CODE [SRV-149] 디스크 볼륨 암호화 미적용

cat << EOF >> $TMP1
[양호]: 모든 디스크 볼륨이 암호화되어 있는 경우
[취약]: 하나 이상의 디스크 볼륨이 암호화되지 않은 경우
EOF

BAR

# 모든 디스크 볼륨 확인
all_volumes=$(lsblk -o NAME,TYPE,MOUNTPOINT,SIZE)

# 암호화된 디스크 볼륨 확인
encrypted_volumes=$(lsblk -o NAME,TYPE,MOUNTPOINT,SIZE,STATE | grep 'crypt')

if [ -z "$encrypted_volumes" ]; then
    WARN "암호화된 디스크 볼륨이 존재하지 않습니다." >> $TMP1
else
    OK "다음의 암호화된 디스크 볼륨이 존재합니다: $encrypted_volumes" >> $TMP1
fi

# 암호화가 필요한 디스크 볼륨이 있는지 확인하고, 권장 사항 기록
if [ -z "$encrypted_volumes" ]; then
    WARN "다음 볼륨은 암호화가 권장됩니다: $all_volumes" >> $TMP1
else
    OK "모든 중요 볼륨이 암호화되었습니다." >> $TMP1
fi

cat $TMP1

echo ; echo
