#!/bin/bash

. function.sh

TMP1=$(basename "$0").log
> $TMP1

BAR

echo "[SRV-016] 불필요한 RPC서비스 활성화 조치" >> $TMP1

# RPC 관련 서비스 목록
rpc_services=("rpc.cmsd" "rpc.ttdbserverd" "sadmind" "rusersd" "walld" "sprayd" "rstatd" "rpc.nisd" "rexd" "rpc.pcnfsd" "rpc.statd" "rpc.ypupdated" "rpc.rquotad" "kcms_server" "cachefsd")

# /etc/xinetd.d 디렉터리 내 서비스 파일 비활성화
if [ -d /etc/xinetd.d ]; then
    for service in "${rpc_services[@]}"; do
        if [ -f "/etc/xinetd.d/$service" ]; then
            sed -i '/disable/ s/no/yes/' "/etc/xinetd.d/$service"
            echo "조치: /etc/xinetd.d/$service 내의 서비스 비활성화" >> $TMP1
        fi
    done
fi

# /etc/inetd.conf 파일 내 서비스 비활성화
if [ -f /etc/inetd.conf ]; then
    for service in "${rpc_services[@]}"; do
        sed -i "/$service/ s/^/#/" /etc/inetd.conf
        echo "조치: /etc/inetd.conf 내의 $service 서비스 비활성화" >> $TMP1
    done
fi

OK "불필요한 RPC 서비스 비활성화 조치 완료" >> $TMP1

BAR

cat $TMP1
echo ; echo
