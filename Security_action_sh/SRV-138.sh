#!/bin/bash

# 결과 파일 정의
TMP1="$(SCRIPTNAME).log"
> "$TMP1"

echo "백업 및 복구 권한 설정 점검" >> "$TMP1"
echo "=====================================" >> "$TMP1"

# 백업 디렉토리 경로 설정
backup_dirs=("/path/to/backup/dir1" "/path/to/backup/dir2") # 실제 백업 디렉토리 경로로 수정해야 함

# 백업 디렉토리 권한 및 소유자 점검
for dir in "${backup_dirs[@]}"; do
  if [ -d "$dir" ]; then
    permissions=$(stat -c %a "$dir")
    owner=$(stat -c %U "$dir")
    # 백업 디렉토리의 소유자 및 권한 확인
    if [[ "$owner" == "backup_user" && "$permissions" -le 700 ]]; then
      echo "OK: $dir has appropriate permissions ($permissions) and owner ($owner)." >> "$TMP1"
    else
      echo "WARN: $dir has inappropriate permissions ($permissions) or owner ($owner)." >> "$TMP1"
    fi
  else
    echo "INFO: $dir directory does not exist." >> "$TMP1"
  fi
done

# 결과 파일 출력
cat "$TMP1"
echo
