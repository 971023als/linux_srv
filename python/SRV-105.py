import subprocess

# 결과 파일 초기화 및 기본 정보 추가
script_name = "SCRIPTNAME"  # 실제 스크립트 이름으로 변경해야 합니다.
tmp1 = f"{script_name}.log"

with open(tmp1, 'w') as f:
    f.write("CODE [SRV-105] 불필요한 시작프로그램 존재\n\n")
    f.write("[양호]: 불필요한 시작 프로그램이 존재하지 않는 경우\n")
    f.write("[취약]: 불필요한 시작 프로그램이 존재하는 경우\n")
    f.write("\n------------------------------------------------------------\n")

def warn(message):
    with open(tmp1, 'a') as f:
        f.write(f"WARN: {message}\n")

def ok(message):
    with open(tmp1, 'a') as f:
        f.write(f"OK: {message}\n")

def check_startup_programs():
    # 시스템 시작 시 실행되는 프로그램 목록 확인
    result = subprocess.run(['systemctl', 'list-unit-files', '--type=service', '--state=enabled'], stdout=subprocess.PIPE, text=True)
    startup_programs = result.stdout.splitlines()

    # 불필요하거나 의심스러운 서비스를 확인
    suspicious_services = False
    for line in startup_programs:
        if 'enabled' in line and 'known_safe_service' not in line:  # 예제 필터링 조건
            service = line.split()[0]
            warn(f"의심스러운 시작 프로그램: {service}")
            suspicious_services = True

    if not suspicious_services:
        ok("시스템에 불필요한 시작 프로그램이 없습니다.")

def main():
    check_startup_programs()

if __name__ == "__main__":
    main()
