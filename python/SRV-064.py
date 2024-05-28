import subprocess
import re

def check_dns_version():
    try:
        # BIND 버전 확인을 위한 rpm 명령어 실행
        rpm_output = subprocess.check_output(["rpm", "-qa"], universal_newlines=True)
        # BIND 버전 확인을 위한 dnf 명령어 실행
        dnf_output = subprocess.check_output(["dnf", "list", "installed", "bind*"], universal_newlines=True)

        # rpm 명령어로 확인한 BIND 버전 패턴 매칭
        rpm_bind_versions = re.findall(r'^bind.*9\.(\d+)\.(\d+).*$', rpm_output, re.MULTILINE)
        # dnf 명령어로 확인한 BIND 버전 패턴 매칭
        dnf_bind_versions = re.findall(r'^bind.*9\.(\d+)\.(\d+).*$', dnf_output, re.MULTILINE)

        # 최신 버전 확인 (예시: 9.18.7 이상)
        for major, minor in rpm_bind_versions + dnf_bind_versions:
            major, minor = int(major), int(minor)
            if major < 18 or (major == 18 and minor < 7):
                return False  # 취약: 최신 버전이 아님
        return True  # 양호: 최신 버전임
    except subprocess.CalledProcessError:
        return None  # 오류: 버전 확인 실패

# 결과 로깅 함수
def log_result(message, file_path):
    with open(file_path, "a") as file:
        file.write(message + "\n")

# 로그 파일 초기화
log_file = "dns_version_check.log"
open(log_file, "w").close()

# DNS 버전 검사 및 결과 로깅
dns_version_check_result = check_dns_version()
if dns_version_check_result is True:
    log_result("OK: DNS 서비스가 최신 버전으로 업데이트되어 있는 경우", log_file)
elif dns_version_check_result is False:
    log_result("WARN: DNS 서비스가 최신 버전으로 업데이트되어 있지 않은 경우", log_file)
else:
    log_result("ERROR: DNS 서비스 버전 확인 중 오류 발생", log_file)

# 로그 파일 출력
with open(log_file, "r") as file:
    print(file.read())
