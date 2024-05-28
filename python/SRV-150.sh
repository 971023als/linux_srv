import subprocess

def check_local_logon_policy():
    # 예시: /etc/ssh/sshd_config 파일에서 PermitRootLogin 설정을 확인합니다.
    sshd_config_path = '/etc/ssh/sshd_config'
    try:
        with open(sshd_config_path, 'r') as file:
            for line in file:
                if line.startswith('PermitRootLogin'):
                    if 'yes' in line:
                        print("취약: PermitRootLogin이 'yes'로 설정되어 있습니다.")
                    else:
                        print("양호: PermitRootLogin이 'no' 또는 제한적으로 설정되어 있습니다.")
                    return
    except FileNotFoundError:
        print(f"파일을 찾을 수 없습니다: {sshd_config_path}")

    print("로컬 로그온 정책을 확인할 수 없습니다.")

if __name__ == "__main__":
    check_local_logon_policy()
