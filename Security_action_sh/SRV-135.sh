#!/bin/bash

# 초기 설정
TMP1="$(SCRIPTNAME).log"
> "$TMP1"

echo "TCP 보안 설정 점검" >> "$TMP1"
echo "=================================" >> "$TMP1"

# 필수 TCP 보안 설정 및 권장 값
declare -A tcp_settings=(
  ["net.ipv4.tcp_syncookies"]="1"
  ["net.ipv4.tcp_max_syn_backlog"]="1024"
  ["net.ipv4.tcp_synack_retries"]="2"
  ["net.ipv4.tcp_syn_retries"]="5"
)

# TCP 보안 설정 확인 및 수정
for setting in "${!tcp_settings[@]}"; do
  current_value=$(sysctl -n $setting 2>/dev/null)
  recommended_value=${tcp_settings[$setting]}

  if [ "$current_value" != "$recommended_value" ]; then
    # 설정을 권장 값으로 변경
    sysctl -w $setting=$recommended_value >/dev/null
    echo "WARN: $setting 설정이 적절하지 않았습니다. 권장 값($recommended_value)으로 변경하였습니다." >> "$TMP1"
  else
    echo "OK: $setting 설정이 적절합니다. 현재 값: $current_value" >> "$TMP1"
  fi
done

# 변경된 설정을 /etc/sysctl.conf에도 적용
for setting in "${!tcp_settings[@]}"; do
  if grep -q "^$setting" /etc/sysctl.conf; then
    sed -i "s/^$setting=.*/$setting=${tcp_settings[$setting]}/" /etc/sysctl.conf
  else
    echo "$setting=${tcp_settings[$setting]}" >> /etc/sysctl.conf
  fi
done

# 변경된 설정 적용
sysctl -p > /dev/null 2>&1

# 결과 파일 출력
cat "$TMP1"
echo
