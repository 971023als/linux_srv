import os
import subprocess
import re

# 결과 파일 초기화
script_name = "SCRIPTNAME.log"  # 실제 스크립트 이름으로 변경해야 합니다.

def write_result(message):
    with open(script_name, 'a') as f:
        f.write(message + "\n")

def check_umask_value():
    # 현재 쉘의 UMASK 값을 확인
    umask_value = os.umask(0)
    os.umask(umask_value)  # 원래 UMASK 값으로 되돌림
    umask_str = format(umask_value, '03o')
    
    if int(umask_str[-2]) < 2 or int(umask_str[-1]) < 2:
        write_result("UMASK 값이 022보다 덜 엄격합니다.")
    else:
        write_result("※ U-56 결과 : 양호(Good)")

def check_umask_in_files():
    files_to_check = ["/etc/profile", "/etc/bash.bashrc", "/etc/csh.login", "/etc/csh.cshrc", "/root/.bashrc", "/root/.profile"]
    # /etc/passwd에서 홈 디렉터리를 가져옴
    users_home_dirs = subprocess.check_output("awk -F: '$7!=\"/bin/false\" && $7!=\"/sbin/nologin\" {print $6}' /etc/passwd", shell=True).decode().strip().split('\n')
    
    for home_dir in users_home_dirs:
        files_to_check.extend([os.path.join(home_dir, file) for file in [".bashrc", ".profile", ".cshrc", ".login"]])
    
    for file_path in files_to_check:
        if os.path.isfile(file_path):
            with open(file_path, 'r') as file:
                for line in file:
                    if re.search(r'^\s*umask\s+\d+', line) and not line.strip().startswith('#'):
                        umask_value = re.findall(r'\d+', line)[0]
                        if int(umask_value, 8) < 0o022:
                            write_result(f"{file_path} 내 UMASK 설정이 022보다 덜 엄격합니다.")
                            return

    write_result("모든 검사된 파일에서 UMASK 설정이 적절합니다.")

def main():
    open(script_name, 'w').close()  # 결과 파일 초기화
    check_umask_value()
    check_umask_in_files()

if __name__ == "__main__":
    main()
