import subprocess
import os
import stat

# 결과 파일 초기화
script_name = "SCRIPTNAME.log"  # 실제 스크립트 이름으로 변경해야 합니다.

def write_result(message):
    with open(script_name, 'a') as f:
        f.write(message + "\n")

def check_pam_su():
    pam_su_path = "/etc/pam.d/su"
    if os.path.exists(pam_su_path):
        with open(pam_su_path, 'r') as file:
            content = file.read()
            if 'pam_wheel.so' in content:
                write_result("OK: /etc/pam.d/su 파일에 pam_wheel.so 모듈이 적절히 설정되어 있습니다.")
                return True
            else:
                write_result("WARN: /etc/pam.d/su 파일에 pam_wheel.so 모듈이 없습니다.")
                return False
    else:
        write_result("WARN: /etc/pam.d/su 파일이 존재하지 않습니다.")
        return False

def check_su_executable_permissions():
    su_executables = ["/bin/su", "/usr/bin/su"]
    found_vulnerable = False
    for executable in su_executables:
        if os.path.exists(executable):
            st = os.stat(executable)
            mode = st.st_mode
            if bool(mode & stat.S_IXOTH) or not bool(mode & stat.S_IXGRP):
                write_result(f"WARN: {executable} 실행 파일의 권한 설정이 취약합니다.")
                found_vulnerable = True
    if not found_vulnerable:
        write_result("OK: su 실행 파일의 권한 설정이 적절합니다.")

def main():
    open(script_name, 'w').close()  # 결과 파일 초기화
    if not check_pam_su():
        check_su_executable_permissions()

if __name__ == "__main__":
    main()
