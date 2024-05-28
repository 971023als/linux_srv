import subprocess

# 파일 이름 설정 및 초기화
script_name = "SCRIPTNAME"  # 실제 스크립트 이름으로 변경해야 합니다.
tmp1 = f"{script_name}.log"

def bar():
    print("-" * 40)

def find_world_writable_files():
    """시스템에서 world writable 파일을 찾습니다."""
    try:
        # `find` 명령어 실행
        command = ['find', '/', '-type', 'f', '-perm', '-2']
        result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
        return result.stdout.splitlines()
    except Exception as e:
        print(f"Error executing find command: {e}")
        return []

def main():
    bar()

    print("[SRV-093] 불필요한 world writable 파일 존재")

    result_msg = "[양호]: 시스템에 불필요한 world writable 파일이 존재하지 않는 경우\n[취약]: 시스템에 불필요한 world writable 파일이 존재하는 경우\n"
    bar()

    # World writable 파일 찾기
    files = find_world_writable_files()

    with open(tmp1, 'w') as file:
        if files:
            file.write("WARN: world writable 설정이 되어있는 파일이 있습니다.\n")
            # 파일 목록 출력 (선택적)
            for f in files:
                file.write(f"{f}\n")
        else:
            file.write("OK: ※ U-15 결과 : 양호(Good)\n")
    
    # 결과 메시지 출력
    print(result_msg)

if __name__ == "__main__":
    main()
