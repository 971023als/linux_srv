#!/bin/bash

# function.sh 파일을 소스로 가져옴
. function.sh

# 로그 파일 이름 설정 (SCRIPTNAME이 스크립트의 이름을 올바르게 반환하는지 확인 필요)
# 아래 예제에서는 현재 스크립트 이름을 기준으로 로그 파일 이름을 설정합니다.
TMP1=$(basename "$0").log

# 로그 파일 초기화
> "$TMP1"

# 001부터 174까지 순회하면서 파일명 생성 및 실행
for i in $(seq -w 1 174); do
  filename="SRV-$i.py"
  if [ -f "$filename" ]; then
    echo "Executing $filename" >> "$TMP1"
    python3 "$filename"
  fi
done

echo ""  >> $TMP1
echo "================================ 진단 결과 요약 ================================" >> $TMP1
echo ""  >> $TMP1
echo "                              ★ 항목 개수 = `cat $TMP1 | grep '결과 : ' | wc -l`" >> $TMP1
echo "                              ☆ 양호 개수 = `cat $TMP1 | grep '결과 : OK' | wc -l`" >> $TMP1
echo "                              ★ 취약 개수 = `cat $TMP1 | grep '결과 : WARN' | wc -l`" >> $TMP1
echo "                              ☆ N/A 개수 = `cat $TMP1 | grep '결과 : N/A' | wc -l`" >> $TMP1
echo ""  >> $TMP1
echo "==============================================================================" >> $TMP1
echo ""  >> $TMP1