import os
import subprocess
import re

# 결과 파일 초기화 및 기본 정보 추가
script_name = "SCRIPTNAME.log"  # 실제 스크립트 이름으로 변경해야 합니다.

def write_result(message):
    with open(script_name, 'a') as f:
        f.write(message + "\n")

def check_path_environment_for_root():
    path_env = os.environ.get('PATH', '')
    if re.search(r'\.:|::', path_env):
        write_result("PATH 환경 변수 내에 '.' 또는 '::'이 포함되어 있습니다.")
    else:
        write_result("※ U-05 결과 : 양호(Good)")

def check_user_home_directory_path_settings():
    path_settings_files = ["/etc/profile", "/etc/.login", "/etc/csh.cshrc", "/etc/csh.login", "/etc/environment", ".profile", ".cshrc", ".login", ".kshrc", ".bash_profile", ".bashrc", ".bash_login"]
    user_homes = subprocess.check_output("awk -F: '$7!=\"/bin/false\" && $7!=\"/sbin/nologin\" && $6!=\"\" {print $6}' /etc/passwd", shell=True).decode().strip().split('\n')
    user_homes += [f"/home/{name}" for name in os.listdir('/home') if os.path.isdir(f"/home/{name}")]
    user_homes.append('/root')

    for user_home in user_homes:
        for file_name in path_settings_files:
            file_path = os.path.join(user_home, file_name)
            if os.path.isfile(file_path):
                with open(file_path, 'r') as file:
                    contents = file.read()
                if re.search(r'PATH=.*\.:|PATH=.*::', contents):
                    write_result(f"{file_path} 파일 내에 안전하지 않은 PATH 설정이 포함되어 있습니다.")
                    return

    write_result("※ U-14 결과 : 양호(Good)")

def main():
    open(script_name, 'w').close()  # 결과 파일 초기화
    check_path_environment_for_root()
    check_user_home_directory_path_settings()

if __name__ == "__main__":
    main()
