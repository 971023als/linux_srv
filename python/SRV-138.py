import os
import stat

# 결과 파일 초기화
script_name = "SCRIPTNAME.log"  # 실제 스크립트 이름으로 변경해야 합니다.

def write_result(message):
    with open(script_name, 'a') as f:
        f.write(message + "\n")

def check_backup_permissions():
    backup_dirs = ["/path/to/backup/dir1", "/path/to/backup/dir2"]  # 백업 디렉토리 경로 예시

    for dir_path in backup_dirs:
        if os.path.isdir(dir_path):
            mode = os.stat(dir_path).st_mode
            permissions = oct(mode)[-3:]
            owner = os.stat(dir_path).st_uid

            # 백업 디렉토리 소유자 및 권한 확인 (소유자 ID 대신 사용자 이름으로 비교하는 경우 os.geteuid() 등 사용)
            if owner == os.geteuid() and int(permissions, 8) <= 0o700:
                write_result(f"OK: {dir_path} 은 적절한 권한({permissions}) 및 소유자를 가집니다.")
            else:
                write_result(f"WARN: {dir_path} 은 부적절한 권한({permissions}) 또는 소유자를 가집니다.")
        else:
            write_result(f"INFO: {dir_path} 디렉토리가 존재하지 않습니다.")

def main():
    open(script_name, 'w').close()  # 결과 파일 초기화
    check_backup_permissions()

if __name__ == "__main__":
    main()
