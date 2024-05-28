# 결과 파일 초기화 및 기본 정보 추가
script_name = "SCRIPTNAME.log"  # 실제 스크립트 이름으로 변경해야 합니다.

def write_result(message):
    with open(script_name, 'a') as f:
        f.write(message + "\n")

def check_stack_protection():
    sysctl_conf_path = "/etc/sysctl.conf"
    try:
        with open(sysctl_conf_path, 'r') as file:
            for line in file:
                if "kernel.randomize_va_space=2" in line:
                    write_result("스택 영역 실행 방지가 활성화되어 있습니다.")
                    return
            write_result("스택 영역 실행 방지가 비활성화되어 있습니다.")
    except FileNotFoundError:
        write_result(f"{sysctl_conf_path} 파일이 존재하지 않습니다.")

def main():
    open(script_name, 'w').close()  # 결과 파일 초기화
    check_stack_protection()

if __name__ == "__main__":
    main()
