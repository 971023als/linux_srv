import re
import os

log_file = "password_policy_check.log"

def log_message(message):
    with open(log_file, "a") as log:
        log.write(message + "\n")

def check_password_policy():
    file_paths = ["/etc/login.defs", "/etc/pam.d/system-auth", "/etc/pam.d/password-auth", "/etc/security/pwquality.conf"]
    patterns = {
        "PASS_MIN_LEN": {"regex": r"PASS_MIN_LEN\s+(\d+)", "min_value": 8, "message": "패스워드 최소 길이가 8 미만입니다."},
        "PASS_MAX_DAYS": {"regex": r"PASS_MAX_DAYS\s+(\d+)", "max_value": 90, "message": "패스워드 최대 사용 기간이 91일 이상입니다."},
        "PASS_MIN_DAYS": {"regex": r"PASS_MIN_DAYS\s+(\d+)", "min_value": 1, "message": "패스워드 최소 사용 기간이 1일 미만입니다."},
        "shadow": {"regex": r":x:", "message": "쉐도우 패스워드를 사용하고 있지 않습니다."}
    }

    # 파일별 설정 검사
    for file_path in file_paths:
        if os.path.exists(file_path):
            with open(file_path, "r") as file:
                content = file.read()
                for key, val in patterns.items():
                    if key != "shadow":
                        matches = re.findall(val["regex"], content, re.MULTILINE)
                        for match in matches:
                            if key in ["PASS_MIN_LEN", "PASS_MIN_DAYS"] and int(match) < val["min_value"]:
                                log_message(val["message"])
                            elif key == "PASS_MAX_DAYS" and int(match) > val["max_value"]:
                                log_message(val["message"])
                    else:
                        if not re.search(val["regex"], content, re.MULTILINE):
                            log_message(val["message"])
        else:
            log_message(f"{file_path} 파일이 존재하지 않습니다.")

# 비밀번호 정책 검사 실행
check_password_policy()

# 결과 파일 출력
with open(log_file, "r") as file:
    print(file.read())
