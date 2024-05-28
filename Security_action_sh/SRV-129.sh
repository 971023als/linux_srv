#!/bin/bash

# 결과 파일 초기화
TMP1="$(SCRIPTNAME).log"
> $TMP1

echo "백신 프로그램 설치 여부 점검" >> $TMP1
echo "=========================" >> $TMP1

# 일반적으로 사용되는 백신 프로그램의 설치 여부를 확인합니다
antivirus_programs=("clamav" "avast" "avg" "avira" "eset")

installed_antivirus=()

for antivirus in "${antivirus_programs[@]}"; do
  if command -v $antivirus &> /dev/null; then
    installed_antivirus+=("$antivirus")
  fi
done

# 설치된 백신 프로그램이 있는지 확인합니다
if [ ${#installed_antivirus[@]} -eq 0 ]; then
  echo "WARN: 설치된 백신 프로그램이 없습니다." >> $TMP1
else
  echo "OK: 설치된 백신 프로그램: ${installed_antivirus[*]}" >> $TMP1
fi

# 결과 출력
cat $TMP1
echo
