#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

echo "[SRV-041] 웹 서비스의 CGI 스크립트 관리 조치" >> $TMP1

# Apache 설정 파일 경로
APACHE_CONFIG_FILE="/etc/apache2/apache2.conf"

# CGI 실행 관련 설정을 제한적으로 변경합니다.
# 여기서는 모든 'Options ExecCGI' 설정을 제거하고, 특정 디렉토리만 CGI를 실행할 수 있도록 설정합니다.
# 모든 'Options ExecCGI' 설정 제거
sed -i '/Options.*ExecCGI/d' "$APACHE_CONFIG_FILE"

# 'AddHandler' 및 'ScriptAlias' 지시어 제거
sed -i '/AddHandler cgi-script/d' "$APACHE_CONFIG_FILE"
sed -i '/ScriptAlias/d' "$APACHE_CONFIG_FILE"

# CGI 스크립트를 실행할 수 있는 안전한 디렉토리 설정 예시
# 안전한 디렉토리 예시: /usr/lib/cgi-bin
echo "<Directory /usr/lib/cgi-bin>" >> "$APACHE_CONFIG_FILE"
echo "    Options +ExecCGI" >> "$APACHE_CONFIG_FILE"
echo "    AddHandler cgi-script .cgi .pl" >> "$APACHE_CONFIG_FILE"
echo "</Directory>" >> "$APACHE_CONFIG_FILE"

echo "Apache 설정에서 CGI 스크립트 실행이 제한되었습니다." >> $TMP1

# Apache 서비스 재시작
systemctl restart apache2

echo "Apache 서비스가 재시작되었습니다." >> $TMP1

BAR

cat "$TMP1"

echo ; echo
