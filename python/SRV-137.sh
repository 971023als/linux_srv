# 결과 파일 초기화
script_name = "SCRIPTNAME.log"  # 실제 스크립트 이름으로 변경해야 합니다.

def write_result(message):
    with open(script_name, 'a') as f:
        f.write(message + "\n")

def check_access_restriction():
    hosts_deny_path = "/etc/hosts.deny"
    hosts_allow_path = "/etc/hosts.allow"

    # /etc/hosts.deny 파일의 존재 및 내용 검사
    if os.path.exists(hosts_deny_path):
        with open(hosts_deny_path, 'r') as file:
            deny_content = file.read()
            if 'ALL: ALL' in deny_content.replace(" ", "").upper():
                # /etc/hosts.allow 파일의 존재 및 내용 검사
                if os.path.exists(hosts_allow_path):
                    with open(hosts_allow_path, 'r') as allow_file:
                        allow_content = allow_file.read()
                        if 'ALL: ALL' in allow_content.replace(" ", "").upper():
                            write_result("WARN: /etc/hosts.allow 파일에 'ALL : ALL' 설정이 있습니다.")
                        else:
                            write_result("OK: 네트워크 서비스의 접근 제한이 적절히 설정된 경우")
                else:
                    write_result("OK: 네트워크 서비스의 접근 제한이 적절히 설정된 경우")
            else:
                write_result("WARN: /etc/hosts.deny 파일에 'ALL : ALL' 설정이 없습니다.")
    else:
        write_result("WARN: /etc/hosts.deny 파일이 없습니다.")

def main():
    open(script_name, 'w').close()  # 결과 파일 초기화
    check_access_restriction()

if __name__ == "__main__":
    import os
    main()
