import subprocess
import re

def check_password_policy():
    # 패스워드 정책 파일들
    policy_files = ["/etc/login.defs", "/etc/pam.d/system-auth", "/etc/pam.d/password-auth", "/etc/security/pwquality.conf"]
    
    # 각 파일별 검사
    for file in policy_files:
        try:
            with open(file, 'r') as f:
                content = f.read()
                # 비밀번호 최소 길이 검사
                if re.search(r"PASS_MIN_LEN\s+[89]|\d{2,}", content) or re.search(r"minlen\s+=\s+[89]|\d{2,}", content):
                    print(f"{file}에서 적절한 패스워드 최소 길이 설정을 확인했습니다.")
                else:
                    print(f"{file}에서 패스워드 최소 길이 설정이 미비합니다.")
                
                # 비밀번호 복잡성 요구사항 검사
                if re.search(r"lcredit\s+=\s+-\d+|ucredit\s+=\s+-\d+|dcredit\s+=\s+-\d+|ocredit\s+=\s+-\d+", content):
                    print(f"{file}에서 적절한 패스워드 복잡성 설정을 확인했습니다.")
                else:
                    print(f"{file}에서 패스워드 복잡성 설정이 미비합니다.")
        except FileNotFoundError:
            print(f"{file} 파일을 찾을 수 없습니다.")
    
    # 패스워드 최대 및 최소 사용 기간 검사
    try:
        output = subprocess.check_output(['grep', 'PASS_MAX_DAYS', '/etc/login.defs']).decode()
        max_days = re.search(r"\d+", output)
        if max_days and int(max_days.group(0)) <= 90:
            print("/etc/login.defs에서 적절한 패스워드 최대 사용 기간을 확인했습니다.")
        else:
            print("/etc/login.defs에서 패스워드 최대 사용 기간 설정이 미비합니다.")
    except subprocess.CalledProcessError:
        print("PASS_MAX_DAYS를 검사할 수 없습니다.")

    # 쉐도우 패스워드 사용 여부 검사
    try:
        output = subprocess.check_output(['awk', '-F:', '$2!="x"', '/etc/passwd']).decode()
        if output:
            print("쉐도우 패스워드를 사용하고 있지 않습니다.")
        else:
            print("모든 계정이 쉐도우 패스워드를 사용하고 있습니다.")
    except subprocess.CalledProcessError:
        print("쉐도우 패스워드 사용 여부를 검사할 수 없습니다.")

check_password_policy()
