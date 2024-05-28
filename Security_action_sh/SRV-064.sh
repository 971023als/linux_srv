#!/bin/bash

# DNS 서비스 버전 업데이트 스크립트
echo "DNS 서비스 버전 업데이트 시작..."

# CentOS/RHEL 기반 시스템
if [ -f /etc/redhat-release ]; then
    echo "CentOS/RHEL 기반 시스템에서 BIND 업데이트를 시도합니다."
    sudo yum update -y bind bind-utils
fi

# Debian/Ubuntu 기반 시스템
if [ -f /etc/debian_version ]; then
    echo "Debian/Ubuntu 기반 시스템에서 BIND 업데이트를 시도합니다."
    sudo apt-get update
    sudo apt-get install -y bind9
fi

# 업데이트 후 버전 확인
bind_version=$(named -v)
echo "현재 BIND 버전: $bind_version"

echo "DNS 서비스 버전 업데이트 완료."
