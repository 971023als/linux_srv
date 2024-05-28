#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

echo "[SRV-014] NFS 접근통제 조치" >> $TMP1

# NFS 설정 파일을 확인하고 조치합니다.
if [ -f /etc/exports ]; then
    # '*' 설정이 있는 줄을 주석 처리합니다.
    sed -i '/\*/ s/^/#/' /etc/exports

    # 'insecure' 옵션이 설정된 줄을 주석 처리합니다.
    sed -i '/insecure/ s/^/#/' /etc/exports

    # 'root_squash' 또는 'all_squash' 옵션이 없는 공유에 대해 root_squash 옵션을 추가합니다.
    while IFS= read -r line; do
        if ! echo "$line" | grep -qE 'root_squash|all_squash'; then
            sed -i "/$(echo "$line" | sed 's/\//\\\//g')/ s/$/ root_squash/" /etc/exports
        fi
    done < <(grep -vE '^#|^\s#' /etc/exports | grep '/')
    
    echo "조치: /etc/exports 파일에서 보안 취약한 설정을 수정하였습니다." >> $TMP1
else
    echo "INFO: /etc/exports 파일이 존재하지 않습니다. NFS 서비스가 활성화되어 있지 않을 수 있습니다." >> $TMP1
fi

BAR

cat $TMP1
echo ; echo
