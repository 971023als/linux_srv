import subprocess

# 파일 이름 설정 및 초기화
script_name = "SCRIPTNAME"  # 실제 스크립트 이름으로 변경해야 합니다.
tmp1 = f"{script_name}.log"

# 로그 파일 초기화
with open(tmp1, 'w') as file:
    pass

def bar():
    print("-" * 40)

def check_remote_registry_service():
    """원격 레지스트리 서비스 상태 확인"""
    try:
        # systemctl을 사용하여 서비스 상태 확인
        subprocess.check_call(['systemctl', 'is-active', '--quiet', 'remote-registry'])
        return True
    except subprocess.CalledProcessError:
        return False

def main():
    result = "결과 메시지:\n"
    bar()

    # 코드 및 불필요한 원격 레지스트리 서비스 활성화 여부 확인
    code = "[SRV-090] 불필요한 원격 레지스트리 서비스 활성화"
    print(code)
    
    if check_remote_registry_service():
        result += "[취약]: 원격 레지스트리 서비스가 활성화되어 있는 경우\n"
        warn_msg = "원격 레지스트리 서비스가 활성화되어 있습니다."
        print(warn_msg)
    else:
        result += "[양호]: 원격 레지스트리 서비스가 비활성화되어 있는 경우\n"
        ok_msg = "원격 레지스트리 서비스가 비활성화되어 있습니다."
        print(ok_msg)
    
    bar()
    
    # 결과 출력
    print(result)
    print()

if __name__ == "__main__":
    main()
