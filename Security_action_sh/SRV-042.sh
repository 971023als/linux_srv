#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

echo "[SRV-042] 웹 서비스 상위 디렉터리 접근 제한 설정 조치" >> $TMP1

# Apache 설정 파일 경로
APACHE_CONFIG_FILES=("/etc/apache2/apache2.conf" "/etc/apache2/sites-available/*" "/etc/httpd/conf/httpd.conf" "/etc/httpd/conf.d/*")

for config_file in "${APACHE_CONFIG_FILES[@]}"; do
    if [ -f "$config_file" ] || [ -d "$config_file" ]; then
        # AllowOverride 설정을 None에서 All로 변경하여 .htaccess 파일을 통한 설정 변경을 허용합니다.
        # Directory 지시어 내에서 상위 디렉터리 접근 제한 설정을 적용합니다.
        sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' $config_file
        echo "조치: $config_file 파일에서 상위 디렉터리 접근 제한 설정을 적용하였습니다." >> $TMP1
    fi
done

# .htaccess 파일을 사용하여 상위 디렉터리 접근을 제한하는 설정 예시
HTACCESS_FILE="/var/www/html/.htaccess"
if [ ! -f "$HTACCESS_FILE" ]; then
    echo "RewriteEngine on" > "$HTACCESS_FILE"
    echo "RewriteCond %{REQUEST_URI} !^/html/" >> "$HTACCESS_FILE"
    echo "RewriteRule ^(.*)$ /html/$1 [L]" >> "$HTACCESS_FILE"
    echo "조치: $HTACCESS_FILE 파일에서 상위 디렉터리 접근 제한 설정을 적용하였습니다." >> $TMP1
fi

# Apache 서비스 재시작
if systemctl is-active --quiet apache2; then
    systemctl restart apache2
    echo "Apache2 서비스가 재시작되었습니다." >> $TMP1
elif systemctl is-active --quiet httpd; then
    systemctl restart httpd
    echo "HTTPD 서비스가 재시작되었습니다." >> $TMP1
else
    echo "Apache/HTTPD 서비스가 설치되지 않았거나 인식할 수 없습니다." >> $TMP1
fi

BAR

cat "$TMP1"

echo ; echo
