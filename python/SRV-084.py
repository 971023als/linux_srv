import os
import pwd
import subprocess

def bar():
    print("=" * 40)

def check_system_files_permissions():
    tmp1 = "scriptname.log"
    with open(tmp1, "w") as result:
        bar()

        header = """
[양호]: 시스템 주요 파일의 권한이 적절하게 설정된 경우
[취약]: 시스템 주요 파일의 권한이 적절하게 설정되지 않은 경우
"""
        result.write(header)
        bar()

        # Check for insecure elements in PATH environment variable
        path_env = os.environ.get("PATH", "")
        if ".:" in path_env or "::" in path_env:
            result.write("WARNING: PATH 환경 변수 내에 '.' 또는 '::'이 포함되어 있습니다.\n")
        else:
            # Additional checks for system and user configuration files
            check_configuration_files(result)
            # Placeholder for further checks, e.g., on system major files
            # This could involve checking permissions on critical files

    with open(tmp1, "r") as file:
        print(file.read())

def check_configuration_files(result):
    path_settings_files = ["/etc/profile", "/etc/bashrc", "/etc/environment"]  # Extend this list as needed
    # Example of checking a single file, extend to loop through path_settings_files
    for file_path in path_settings_files:
        if os.path.isfile(file_path):
            with open(file_path) as file:
                if any(".:" in line or "::" in line for line in file):
                    result.write(f"WARNING: {file_path} 파일에 PATH 설정이 적절치 않습니다.\n")

check_system_files_permissions()
