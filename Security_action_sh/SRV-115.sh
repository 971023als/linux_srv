#!/bin/bash

. function.sh

# 결과 파일 정의
TMP1="$(SCRIPTNAME).log"
> $TMP1

echo "로그의 정기적 검토 및 보고 상태 점검" >> $TMP1
echo "=====================================" >> $TMP1

# 로그 검토 스크립트 경로
log_review_script="/usr/local/bin/log_review.sh"

# 로그 보고서 경로
log_report="/var/log/log_review_report.txt"

# 로그 검토 스크립트 존재 여부 확인 및 생성
if [ ! -f "$log_review_script" ]; then
  echo "로그 검토 스크립트가 존재하지 않습니다. 기본 스크립트를 생성합니다." >> $TMP1
  cat << 'EOF' > "$log_review_script"
#!/bin/bash
log_files="/var/log/syslog /var/log/auth.log" # 검토할 로그 파일 목록
output_file="/var/log/log_review_report.txt" # 로그 보고서 파일

echo "Log Review Report - $(date)" > "$output_file"
for log_file in $log_files; do
  echo "Reviewing $log_file" >> "$output_file"
  grep -E 'error|failed|denied' "$log_file" >> "$output_file"
done
EOF
  chmod +x "$log_review_script"
  echo "기본 로그 검토 스크립트가 생성되었습니다: $log_review_script" >> $TMP1
else
  echo "로그 검토 스크립트가 존재합니다: $log_review_script" >> $TMP1
fi

# 로그 보고서 존재 여부 확인 및 생성
if [ ! -f "$log_report" ]; then
  echo "로그 보고서가 존재하지 않습니다. 보고서를 생성합니다." >> $TMP1
  bash "$log_review_script"
  echo "로그 보고서가 생성되었습니다: $log_report" >> $TMP1
else
  echo "최신 로그 보고서가 존재합니다: $log_report" >> $TMP1
fi

# 결과 파일 출력
cat $TMP1
echo
