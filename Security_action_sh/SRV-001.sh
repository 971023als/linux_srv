#!/bin/bash

. function.sh

TMP1=$(basename "$0").log
> $TMP1

BAR

CODE [SRV-001] SNMP 서비스 Get Community 스트링 설정 오류

cat << EOF >> $TMP1

[양호]: SNMP Community 스트링이 복잡하고 예측 불가능하게 설정된 경우

[취약]: SNMP Community 스트링이 기본값이거나 예측 가능하게 설정된 경우

EOF

BAR

"[SRV-001] SNMP 서비스 Get Community 스트링 설정 오류" >> $TMP1

# Check if SNMP service is running
ps_snmp_count=$(ps -ef | grep -i 'snmp' | grep -v 'grep' | wc -l)

snmpdconf_file="/etc/snmp/snmpd.conf" # Default path for Linux; might need adjustment for other OS

if [ $ps_snmp_count -gt 0 ]; then
    if [ -f "$snmpdconf_file" ]; then
        if grep -qiE 'public|private' $snmpdconf_file; then
            # Generate a new complex Community string
            new_community=$(openssl rand -hex 8)
            
            # Replace "public" and "private" with the new complex Community string
            sed -i -e "s/public/$new_community/g" -e "s/private/$new_community/g" $snmpdconf_file
            
            WARN "기본 SNMP Community 스트링(public/private)이 복잡한 값으로 변경됨: $new_community" >> $TMP1
            
            # Restart SNMP service to apply changes
            systemctl restart snmpd
        else
            OK "기본 SNMP Community 스트링(public/private)이 사용되지 않음" >> $TMP1
        fi
    else
        WARN "SNMP 구성 파일($snmpdconf_file)을 찾을 수 없음" >> $TMP1
    fi
else
    OK "SNMP 서비스가 실행 중이지 않습니다." >> $TMP1
fi

BAR

cat $TMP1
echo ; echo
