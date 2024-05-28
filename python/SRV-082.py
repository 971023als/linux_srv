import os
import subprocess
import pwd

def bar():
    print("=" * 40)

def check_system_directories_permissions():
    tmp1 = "scriptname.log"
    with open(tmp1, "w") as log_file:
        bar()
        header = """
[양호]: 시스템 주요 디렉터리의 권한이 적절히 설정된 경우
[취약]: 시스템 주요 디렉터리의 권한이 적절히 설정되지 않은 경우
"""
        log_file.write(header)
        bar()

        # Check PATH environment variable for insecure elements
        path_env = os.environ.get("PATH", "")
        if ".:" in path_env or "::" in path_env:
            log_file.write("WARNING: PATH 환경 변수 내에 '.' 또는 '::'이 포함되어 있습니다.\n")
            return
        
        # Check system configuration files for insecure PATH settings
        path_settings_files = ["/etc/profile", "/etc/.login", "/etc/csh.cshrc", "/etc/csh.login", "/etc/environment"]
        for file_path in path_settings_files:
            if os.path.isfile(file_path):
                with open(file_path, 'r') as file:
                    if any(".:" in line or "::" in line for line in file if "PATH=" in line and not line.startswith("#")):
                        log_file.write(f"WARNING: {file_path}에 '.' 또는 '::'이 포함된 PATH 환경 변수 설정이 있습니다.\n")
                        return
        
        # Check user home directories for insecure PATH settings and permissions
        users_home_dirs = [pwd.getpwnam(user).pw_dir for user in os.listdir('/home')] + ['/root']
        startup_files = [".profile", ".cshrc", ".login", ".kshrc", ".bash_profile", ".bashrc", ".bash_login"]
        for home_dir in users_home_dirs:
            for startup_file in startup_files:
                file_path = os.path.join(home_dir, startup_file)
                if os.path.isfile(file_path):
                    with open(file_path, 'r') as file:
                        if any(".:" in line or "::" in line for line in file if "PATH=" in line and not line.startswith("#")):
                            log_file.write(f"WARNING: {file_path}에 '.' 또는 '::'이 포함된 PATH 환경 변수 설정이 있습니다.\n")
                            return
                        file_stat = os.stat(file_path)
                        if file_stat.st_mode & 0o002:  # Check if 'other' has write permission
                            log_file.write(f"WARNING: {file_path}에 다른 사용자의 쓰기 권한이 설정되어 있습니다.\n")
                            return
        
        log_file.write("※ U-05 및 U-14 결과 : 양호(Good)\n")

    with open(tmp1, "r") as file:
        print(file.read())

check_system_directories_permissions()
