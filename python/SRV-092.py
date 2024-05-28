import os

# 파일 이름 설정 및 초기화
script_name = "SCRIPTNAME"  # 실제 스크립트 이름으로 변경해야 합니다.
tmp1 = f"{script_name}.log"

# 로그 파일 초기화
with open(tmp1, 'w') as file:
    pass

def bar():
    print("-" * 40)

def check_home_directories():
    """`/etc/passwd`에서 사용자 홈 디렉터리 정보를 추출하고 확인합니다."""
    with open("/etc/passwd", "r") as passwd_file:
        for line in passwd_file:
            parts = line.strip().split(':')
            if len(parts) >= 6:
                user, home_dir = parts[0], parts[5]
                if not os.path.isdir(home_dir) or not home_dir:
                    print(f"WARN: 사용자 {user} 에 대한 홈 디렉터리({home_dir})가 잘못 설정되었습니다.")
                else:
                    print(f"OK: 사용자 {user} 의 홈 디렉터리({home_dir})가 적절히 설정되었습니다.")

def main():
    bar()

    print("[SRV-092] 사용자 홈 디렉터리 설정 미흡")

    result_msg = "[양호]: 모든 사용자의 홈 디렉터리가 적절히 설정되어 있는 경우\n[취약]: 하나 이상의 사용자의 홈 디렉터리가 적절히 설정되지 않은 경우\n"
    bar()

    check_home_directories()

    # 결과 메시지 출력
    print(result_msg)

if __name__ == "__main__":
    main()
