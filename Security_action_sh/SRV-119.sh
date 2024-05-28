#!/bin/bash

# 결과 파일 초기화
TMP1="$(SCRIPTNAME).log"
> $TMP1

echo "백신 프로그램 업데이트 상태 점검" >> $TMP1
echo "=====================================" >> $TMP1

# ClamAV 버전 확인
clamav_version=$(clamscan --version | grep -oP 'ClamAV \K[0-9.]+')

# 최신 ClamAV 버전 확인 (예시 URL, 실제 URL은 변경될 수 있음)
latest_clamav_version=$(curl -s https://www.clamav.net/downloads | grep -oP 'Latest stable release is ClamAV \K[0-9.]+')

# 버전 비교 및 결과 출력
if [ "$clamav_version" == "$latest_clamav_version" ]; then
  echo "OK: ClamAV가 최신 버전입니다. 현재 버전: $clamav_version" >> $TMP1
else
  echo "WARN: ClamAV가 최신 버전이 아닙니다. 현재 버전: $clamav_version, 최신 버전: $latest_clamav_version" >> $TMP1
fi

# 결과 파일 출력
cat $TMP1
echo
