import os
import pwd
import subprocess

# 결과 파일 초기화 및 기본 정보 추가
script_name = "SCRIPTNAME"  # 실제 스크립트 이름으로 변경해야 합니다.
tmp1 = f"{script_name}.log"
with open(tmp1, 'w') as f:
    f.write("CODE [SRV-096] 사용자 환경파일의 소유자 또는 권한 설정 미흡\n\n")
    f.write("[양호]: 사용자 환경 파일의 소유자가 해당 사용자이고, 권한이 적절하게 설정된 경우\n")
    f.write("[취약]: 사용자 환경 파일의 소유자가 해당 사용자가 아니거나, 권한이 부적절하게 설정된 경우\n")
    f.write("\n------------------------------------------------------------\n")

def warn(message):
    with open(tmp1, 'a') as f:
        f.write(f"WARN: {message}\n")

def ok(message):
    with open(tmp1, 'a') as f:
        f.write(f"OK: {message}\n")

def extract_user_homedirectory_info():
    user_info = {user.pw_name: user.pw_dir for user in pwd.getpwall() if user.pw_shell not in ["/bin/false", "/sbin/nologin"] and user.pw_dir}
    return user_info

def check_user_environment_files(user_info):
    start_files = [".profile", ".cshrc", ".login", ".kshrc", ".bash_profile", ".bashrc", ".bash_login"]
    for user, homedir in user_info.items():
        for filename in start_files:
            filepath = os.path.join(homedir, filename)
            if os.path.isfile(filepath):
                stat_info = os.stat(filepath)
                file_owner = pwd.getpwuid(stat_info.st_uid).pw_name
                if (file_owner != user and file_owner != "root") or (stat_info.st_mode & 0o002):
                    warn(f"{homedir} 홈 디렉터리 내 {filename} 환경 변수 파일의 설정이 적절하지 않습니다.")
                    break
        else:  # If no break
            ok(f"{homedir} 홈 디렉터리 내 검사된 모든 시작 파일이 적절한 소유자를 가지며, 다른 사용자(other)의 쓰기(w) 권한이 없습니다.")

def main():
    user_info = extract_user_homedirectory_info()
    check_user_environment_files(user_info)
    # 기타 검사 기능들은 필요에 따라 추가 구현

if __name__ == "__main__":
    main()

# 결과 파일 출력
with open(tmp1, 'r') as f:
    print(f.read())
