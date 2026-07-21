import os
import stat

# 중요 파일 목록
important_files = [
    "/etc/passwd",
    "/etc/shadow",
    "/etc/hosts",
    "/etc/xinetd.conf",
    "/etc/inetd.conf",
    "/etc/exports",
    # 추가 파일이 필요한 경우 여기에 추가
]

def check_file_permissions(file_path):
    try:
        # 파일 메타데이터 가져오기
        file_stat = os.stat(file_path)
        
        # 소유자, 그룹, 기타 사용자 권한 분석
        owner_permission = oct(file_stat.st_mode & stat.S_IRWXU)
        group_permission = oct(file_stat.st_mode & stat.S_IRWXG)
        others_permission = oct(file_stat.st_mode & stat.S_IRWXO)

        # 파일 소유자 확인
        owner = stat.filemode(file_stat.st_mode)[1:4]
        if owner == 'rwx':
            print(f"OK: {file_path} has appropriate owner permissions.")
        else:
            print(f"WARN: {file_path} has inappropriate owner permissions.")

        # 그룹 및 기타 사용자 권한 확인
        if group_permission == '0o0' and others_permission == '0o0':
            print(f"OK: {file_path} has appropriate group and others permissions.")
        else:
            print(f"WARN: {file_path} has inappropriate group or others permissions.")

    except FileNotFoundError:
        print(f"INFO: {file_path} does not exist.")

def main():
    for file_path in important_files:
        check_file_permissions(file_path)

if __name__ == "__main__":
    main()
