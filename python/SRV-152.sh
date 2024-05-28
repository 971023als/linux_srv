import subprocess
import os

def check_ssh_user_group_restriction():
    # sshd_config 파일 위치 찾기
    find_command = "find / -name sshd_config -type f 2>/dev/null"
    sshd_config_files = subprocess.getoutput(find_command).split('\n')
    
    if not sshd_config_files:
        print("WARN: sshd_config 파일이 없습니다.")
        return
    
    permit_root_login = False
    
    for sshd_config_file in sshd_config_files:
        with open(sshd_config_file, 'r') as file:
            for line in file:
                if line.strip().startswith("PermitRootLogin") and "no" in line:
                    permit_root_login = True
                    break
    
    if permit_root_login:
        print("OK: sshd_config 파일에서 root 계정의 원격 접속이 제한되어 있습니다.")
    else:
        print("WARN: ssh 서비스를 사용하고, sshd_config 파일에서 root 계정의 원격 접속이 허용되어 있습니다.")

if __name__ == "__main__":
    check_ssh_user_group_restriction()
