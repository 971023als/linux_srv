#!/bin/bash

# 숨김 파일 및 디렉터리 검색 후 로그 파일에 기록
find / -name ".*" -type f > hidden_files.log
find / -name ".*" -type d > hidden_dirs.log

echo "숨김 파일 목록: hidden_files.log"
echo "숨김 디렉터리 목록: hidden_dirs.log"

echo "검토 후 불필요한 항목을 수동으로 제거하십시오."
