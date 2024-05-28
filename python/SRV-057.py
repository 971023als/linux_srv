import os
import stat

def BAR():
    print("=" * 40)

def log_message(message, file_path, mode='a'):
    with open(file_path, mode) as f:
        f.write(message + "\n")

# 결과 파일 초기화
tmp1 = "SCRIPTNAME.log"  # 'SCRIPTNAME'을 실제 스크립트 이름으로 바꿔주세요.
log_message("", tmp1, 'w')  # 로그 파일을 초기화합니다.

BAR()

code = "[SRV-057] 웹 서비스 경로 내 파일의 접근 통제 미흡"
description = "[양호]: 웹 서비스 경로 내 파일의 접근 권한이 적절하게 설정된 경우\n[취약]: 웹 서비스 경로 내 파일의 접근 권한이 적절하게 설정되지 않은 경우\n"
log_message(f"{code}\n{description}", tmp1)

BAR()

# 웹 서비스 경로 설정
web_service_path = "/var/www/html"  # 실제 경로에 맞게 조정하세요.

# 웹 서비스 경로 내 파일 접근 권한 확인
incorrect_permissions = False
for root, dirs, files in os.walk(web_service_path):
    for file in files:
        file_path = os.path.join(root, file)
        file_stat = os.stat(file_path)
        # 파일 권한이 755 이상인지 확인
        if not (file_stat.st_mode & stat.S_IRWXU == stat.S_IRUSR | stat.S_IXUSR | stat.S_IWUSR and
                file_stat.st_mode & stat.S_IRGRP | stat.S_IXGRP == stat.S_IRGRP | stat.S_IXGRP and
                file_stat.st_mode & stat.S_IROTH | stat.S_IXOTH == stat.S_IROTH | stat.S_IXOTH):
            log_message(f"WARN: 부적절한 파일 권한이 있습니다. ({file_path})", tmp1)
            incorrect_permissions = True
            break  # 한 번 부적절한 권한을 발견하면 반복을 중단합니다.

if not incorrect_permissions:
    log_message("OK: 웹 서비스 경로 내의 모든 파일의 권한이 적절하게 설정되어 있습니다.", tmp1)

BAR()

# 최종 결과를 출력합니다.
with open(tmp1, 'r') as f:
    print(f.read())
print()
