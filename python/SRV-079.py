import subprocess
import os

def bar():
    print("=" * 40)

def check_world_writable_files():
    tmp1 = "scriptname.log"
    with open(tmp1, "w") as log_file:
        bar()

        # Message about checking inappropriate permissions for anonymous users
        message = """
[양호]: 익명 사용자에게 부적절한 권한이 적용되지 않은 경우
[취약]: 익명 사용자에게 부적절한 권한이 적용된 경우
"""
        log_file.write(message)
        bar()

        # Execute the find command to search for world-writable files
        find_command = "find / -type f -perm -2 -print 2>/dev/null"
        result = subprocess.run(find_command, shell=True, text=True, capture_output=True)
        files = result.stdout.splitlines()

        if files:
            warning_message = " world writable 설정이 되어있는 파일이 있습니다.\n"
            log_file.write(warning_message)
        else:
            ok_message = "※ U-15 결과 : 양호(Good)\n"
            log_file.write(ok_message)

    # Read and print the content of log file
    with open(tmp1, "r") as log_file:
        print(log_file.read())

# Execute the check
check_world_writable_files()
