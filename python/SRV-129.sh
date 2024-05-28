import subprocess

# 결과 파일 초기화
script_name = "SCRIPTNAME.log"  # 실제 스크립트 이름으로 변경해야 합니다.

def write_result(message):
    with open(script_name, 'a') as f:
        f.write(message + "\n")

def check_installed_antivirus():
    antivirus_programs = ["clamav", "avast", "avg", "avira", "eset"]
    installed_antivirus = []

    for antivirus in antivirus_programs:
        try:
            subprocess.check_output(['command', '-v', antivirus], stderr=subprocess.STDOUT)
            installed_antivirus.append(antivirus)
        except subprocess.CalledProcessError:
            continue

    if not installed_antivirus:
        write_result("WARN: 설치된 백신 프로그램이 없습니다.")
    else:
        installed_str = ", ".join(installed_antivirus)
        write_result(f"OK: 설치된 백신 프로그램: {installed_str}")

def main():
    open(script_name, 'w').close()  # 결과 파일 초기화
    check_installed_antivirus()

if __name__ == "__main__":
    main()
