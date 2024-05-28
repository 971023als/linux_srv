import os
import stat

def bar():
    print("=" * 40)

def check_startup_script_permissions():
    tmp1 = "scriptname.log"
    with open(tmp1, "w") as result:
        bar()

        header = """
[양호]: 시스템 스타트업 스크립트의 권한이 적절히 설정된 경우
[취약]: 시스템 스타트업 스크립트의 권한이 적절히 설정되지 않은 경우
"""
        result.write(header)
        bar()

        # Directories to check for startup scripts
        startup_dirs = ["/etc/init.d", "/etc/rc.d", "/etc/systemd", "/usr/lib/systemd"]

        for dir_path in startup_dirs:
            if os.path.isdir(dir_path):
                for root, dirs, files in os.walk(dir_path):
                    for file in files:
                        if file.endswith(".sh") or file.endswith(".service"):
                            file_path = os.path.join(root, file)
                            file_stat = os.stat(file_path)
                            permissions = oct(file_stat.st_mode)[-3:]
                            if int(permissions, 8) <= 0o755:
                                result.write(f"OK: {file_path} 스크립트의 권한이 적절합니다. (권한: {permissions})\n")
                            else:
                                result.write(f"WARN: {file_path} 스크립트의 권한이 적절하지 않습니다. (권한: {permissions})\n")
            else:
                result.write(f"INFO: {dir_path} 디렉터리가 존재하지 않습니다.\n")

    with open(tmp1, "r") as file:
        print(file.read())

check_startup_script_permissions()
