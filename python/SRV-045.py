import subprocess
import re

def BAR():
    print("=" * 40)

def log_message(message, file_path, mode='a'):
    with open(file_path, mode) as f:
        f.write(message + "\n")

# 결과 파일 초기화
tmp1 = "SCRIPTNAME.log"  # 'SCRIPTNAME'을 실제 스크립트 이름으로 바꿔주세요.
log_message("", tmp1, 'w')  # 로그 파일을 초기화합니다.

BAR()

code = "[SRV-045] 웹 서비스 프로세스 권한 제한 미비"
description = "[양호]: 웹 서비스 프로세스가 root 권한으로 실행되지 않는 경우\n[취약]: 웹 서비스 프로세스가 root 권한으로 실행되는 경우\n"
log_message(f"{code}\n{description}", tmp1)

BAR()

webconf_files = [".htaccess", "httpd.conf", "apache2.conf"]
warnings_found = False

for conf_file in webconf_files:
    find_results = subprocess.getoutput(f"find / -name {conf_file} -type f 2>/dev/null").split('\n')
    
    for result_path in find_results:
        if not result_path.strip():
            continue

        with open(result_path, 'r') as file:
            content = file.read()
            # Check for Group root directive
            if re.search(r'^\s*Group\s+root', content, re.MULTILINE):
                log_message(f"WARN: Apache 데몬이 root 권한으로 구동되도록 설정되어 있습니다. ({result_path})", tmp1)
                warnings_found = True
                break
            else:
                # Extract Group value
                group_matches = re.findall(r'^\s*Group\s+(\S+)', content, re.MULTILINE)
                for group in group_matches:
                    if group == 'root':
                        log_message(f"WARN: Apache 데몬이 root 권한으로 구동되도록 설정되어 있습니다. ({result_path})", tmp1)
                        warnings_found = True
                        break

if not warnings_found:
    log_message("OK: ※ 양호(Good)", tmp1)

BAR()

# 최종 결과를 출력합니다.
with open(tmp1, 'r') as f:
    print(f.read())
print()
