import subprocess
import os

def check_web_server_info_exposure():
    webconf_files = [".htaccess", "httpd.conf", "apache2.conf"]
    webconf_file_found = False
    apache_running = False

    # 웹 서버 프로세스 확인
    ps_output = subprocess.run(["ps", "-ef"], capture_output=True, text=True)
    if "httpd" in ps_output.stdout or "apache2" in ps_output.stdout:
        apache_running = True

    # 설정 파일 검색 및 확인
    for webconf_file in webconf_files:
        find_command = ["find", "/", "-name", webconf_file, "-type", "f"]
        find_result = subprocess.run(find_command, capture_output=True, text=True)
        if find_result.stdout:
            webconf_file_found = True
            for line in find_result.stdout.splitlines():
                with open(line, 'r') as file:
                    content = file.read()
                    if "ServerTokens Prod" in content and "ServerSignature Off" in content:
                        print(f"OK: 설정이 적절한 파일 발견: {line}")
                    else:
                        print(f"WARN: {line} 파일에 ServerTokens Prod, ServerSignature Off 설정이 없습니다.")
                        return

    if apache_running and not webconf_file_found:
        print("WARN: Apache 서비스를 사용하고, ServerTokens Prod, ServerSignature Off를 설정하는 파일이 없습니다.")
    else:
        print("OK: 모든 설정이 양호합니다.")

if __name__ == "__main__":
    check_web_server_info_exposure()
