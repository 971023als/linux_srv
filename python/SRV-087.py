import subprocess
import os
import stat

def bar():
    print("=" * 40)

def check_c_compiler_permissions():
    tmp1 = "scriptname.log"
    with open(tmp1, "w") as result:
        bar()

        header = """
[양호]: C 컴파일러가 존재하지 않거나, 적절한 권한으로 설정된 경우
[취약]: C 컴파일러가 존재하며 권한 설정이 미흡한 경우
"""
        result.write(header)
        bar()

        try:
            # Check for gcc compiler path
            compiler_path = subprocess.check_output(["which", "gcc"], text=True).strip()
            if compiler_path:
                # Check compiler permissions
                compiler_perms = os.stat(compiler_path).st_mode
                if compiler_perms & 0o777 <= 0o755:
                    result.write(f"OK: C 컴파일러(gcc)의 권한이 적절합니다. 권한: {oct(compiler_perms)[-3:]}\n")
                else:
                    result.write(f"WARN: C 컴파일러(gcc)의 권한이 부적절합니다. 권한: {oct(compiler_perms)[-3:]}\n")
        except subprocess.CalledProcessError:
            # gcc not found
            result.write("OK: C 컴파일러(gcc)가 시스템에 설치되어 있지 않습니다.\n")

    with open(tmp1, "r") as file:
        print(file.read())

check_c_compiler_permissions()
