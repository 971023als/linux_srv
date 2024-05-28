#!/bin/bash

# 백업 디렉터리 설정
BACKUP_DIR="/backup/dev"

# 백업 디렉터리가 존재하지 않으면 생성
if [ ! -d "$BACKUP_DIR" ]; then
    echo "백업 디렉터리 $BACKUP_DIR 생성 중..."
    mkdir -p "$BACKUP_DIR"
fi

# /dev 디렉터리 내 불필요한 파일 검색 및 백업 후 제거
find /dev -type f -print0 | while IFS= read -r -d '' file; do
    # 백업 파일 경로 설정
    BACKUP_FILE="$BACKUP_DIR$(echo $file | sed 's/^\///')"
    BACKUP_FILE_DIR=$(dirname "$BACKUP_FILE")

    # 백업 파일 디렉터리가 존재하지 않으면 생성
    if [ ! -d "$BACKUP_FILE_DIR" ]; then
        mkdir -p "$BACKUP_FILE_DIR"
    fi

    # 파일을 백업 디렉터리로 복사
    echo "파일 백업: $file -> $BACKUP_FILE"
    cp -a "$file" "$BACKUP_FILE"

    # 원본 파일 삭제
    echo "불필요한 파일 제거: $file"
    rm -f "$file"
done

echo "불필요한 파일 제거 작업 완료."
