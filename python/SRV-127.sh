import re
import subprocess

# 결과 파일 초기화
script_name = "SCRIPTNAME.log"  # 실제 스크립트 이름으로 변경해야 합니다.

def write_result(message):
    with open(script_name, 'a') as f:
        f.write(message + "\n")

def check_account_lock_threshold():
    files_to_check = ["/etc/pam.d/system-auth", "/etc/pam.d/password-auth"]
    deny_modules = ["pam_tally2.so", "pam_faillock.so"]
    settings_found = False
    threshold_exceeded = False

    for file_path in files_to_check:
        if not os.path.exists(file_path):
            continue

        with open(file_path, 'r') as file:
            file_content = file.read()

        for module in deny_modules:
            if module in file_content:
                settings_found = True
                # Find all 'deny' settings for the module
                deny_values = re.findall(rf"{module}.*deny=\d+", file_content)
                for value in deny_values:
                    # Extract the actual numeric value of 'deny'
                    deny_count = int(re.search(r"deny=(\d+)", value).group(1))
                    if deny_count >= 11:
                        threshold_exceeded = True
                        write_result(f"WARN: {file_path} 파일에 계정 잠금 임계값이 11회 이상으로 설정되어 있습니다.")
                        return  # Early return on finding any threshold exceeded

    if not settings_found:
        write_result("WARN: 계정 잠금 임계값을 설정하는 파일이 없습니다.")
    elif not threshold_exceeded:
        write_result("OK: 계정 잠금 임계값이 적절하게 설정되어 있습니다.")

def main():
    open(script_name, 'w').close()  # 결과 파일 초기화
    check_account_lock_threshold()

if __name__ == "__main__":
    main()
