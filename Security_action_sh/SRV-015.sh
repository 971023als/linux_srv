#!/bin/bash

. function.sh

TMP1=$(basename "$0").log
> $TMP1

BAR

echo "[SRV-015] 불필요한 NFS 서비스 실행 조치" >> $TMP1

# NFS 서비스 관련 데몬 비활성화
systemctl is-active --quiet nfs-server && systemctl stop nfs-server && systemctl disable nfs-server
systemctl is-active --quiet rpcbind && systemctl stop rpcbind && systemctl disable rpcbind
systemctl is-active --quiet rpc-statd && systemctl stop rpc-statd && systemctl disable rpc-statd
systemctl is-active --quiet nfs-lock && systemctl stop nfs-lock && systemctl disable nfs-lock
systemctl is-active --quiet rpc-idmapd && systemctl stop rpc-idmapd && systemctl disable rpc-idmapd

if [ $? -eq 0 ]; then
    OK "불필요한 NFS 서비스 관련 데몬을 비활성화하였습니다." >> $TMP1
else
    WARN "불필요한 NFS 서비스 관련 데몬 비활성화에 실패하였습니다. 수동 조치가 필요합니다." >> $TMP1
fi

BAR

cat $TMP1
echo ; echo
