#!/bin/bash

# /etc/ftpusers 파일의 소유자 및 권한 수정
ftpusers_files=("/etc/ftpusers" "/etc/pure-ftpd/ftpusers" "/etc/wu-ftpd/ftpusers" "/etc/vsftpd/ftpusers" "/etc/proftpd/ftpusers" "/etc/ftpd/ftpusers" "/etc/vsftpd.ftpusers" "/etc/vsftpd.user_list" "/etc/vsftpd/user_list")

for file in "${ftpusers_files[@]}"; do
    if [ -f "$file" ]; then
        echo "처리 중: $file"
        # 소유자를 root로 변경
        chown root "$file"
        # 권한을 640으로 설정
        chmod 640 "$file"
        echo "$file 파일의 소유자를 root로 변경하고 권한을 640으로 설정했습니다."
    else
        echo "$file 파일이 존재하지 않습니다."
    fi
done

echo "ftpusers 파일의 소유자 및 권한 수정 작업이 완료되었습니다."
