#!/bin/bash

# 초기 설정
. function.sh
TMP1=$(SCRIPTNAME).log
> $TMP1
BAR

# 코드 식별자
CODE [SRV-172] 불필요한 시스템 자원 공유 존재

# NFS 공유 상태 검사
echo "NFS 공유 상태를 검사합니다..."
nfs_shares=$(showmount -e localhost)
if [ ! -z "$nfs_shares" ]; then
    echo "NFS에서 다음 공유가 발견되었습니다:"
    echo "$nfs_shares"
    read -p "이 NFS 공유를 제거하시겠습니까? (y/n): " answer
    if [[ $answer == "y" ]]; then
        echo "NFS 공유 제거를 위한 관리자 조치가 필요합니다."
        # NFS 공유 제거 로직 구현 필요
    fi
else
    OK "NFS에서 불필요한 공유가 존재하지 않습니다."
fi

# Samba 공유 상태 검사
echo "Samba 공유 상태를 검사합니다..."
samba_shares=$(smbstatus -S)
if [ ! -z "$samba_shares" ]; then
    echo "Samba에서 다음 공유가 발견되었습니다:"
    echo "$samba_shares"
    read -p "이 Samba 공유를 제거하시겠습니까? (y/n): " answer
    if [[ $answer == "y" ]]; then
        echo "Samba 공유 제거를 위한 관리자 조치가 필요합니다."
        # Samba 공유 제거 로직 구현 필요
    fi
else
    OK "Samba에서 불필요한 공유가 존재하지 않습니다."
fi

# 결과 출력
cat $result
echo ; echo
