import os
import subprocess

def bar():
    print("=" * 40)

def check_crontab_permissions():
    tmp1 = "scriptname.log"
    with open(tmp1, "w") as log_file:
        bar()

        header = """
[양호]: Crontab 설정파일의 권한이 적절히 설정된 경우
[취약]: Crontab 설정파일의 권한이 적절히 설정되지 않은 경우
"""
        log_file.write(header)
        bar()

        # Default crontab paths plus the one found by `which crontab`
        crontab_paths = ["/usr/bin/crontab", "/usr/sbin/crontab", "/bin/crontab"]
        which_crontab_path = subprocess.getoutput("which crontab")
        if which_crontab_path:
            crontab_paths.append(which_crontab_path)

        # Check permissions for crontab command files
        for path in crontab_paths:
            if os.path.isfile(path):
                stat_result = os.stat(path)
                mode = stat_result.st_mode
                if not (mode & 0o207):  # Checks if 'other' has no permissions
                    if not (mode & 0o7070):  # Checks if 'group' has restricted permissions
                        log_file.write(f"OK: {path} has secure permissions.\n")
                    else:
                        log_file.write(f"WARNING: {path} has insecure group permissions.\n")
                else:
                    log_file.write(f"WARNING: {path} has insecure permissions.\n")

        # Directories and files to check
        cron_directories = ["/etc/cron.hourly", "/etc/cron.daily", "/etc/cron.weekly", "/etc/cron.monthly", "/var/spool/cron", "/var/spool/cron/crontabs"]
        cron_files = ["/etc/crontab", "/etc/cron.allow", "/etc/cron.deny"]

        # Find files in cron directories
        for directory in cron_directories:
            if os.path.isdir(directory):
                for root, dirs, files in os.walk(directory):
                    for name in files:
                        cron_files.append(os.path.join(root, name))

        # Check permissions for cron files
        for cron_file in cron_files:
            if os.path.isfile(cron_file):
                stat_result = os.stat(cron_file)
                owner = stat_result.st_uid
                mode = stat_result.st_mode
                if owner == 0:  # Checks if owner is root
                    if not (mode & 0o22):  # Checks if 'other' has no write permission
                        if not (mode & 0o220):  # Checks if 'group' has restricted permissions
                            log_file.write(f"OK: {cron_file} has secure permissions.\n")
                        else:
                            log_file.write(f"WARNING: {cron_file} has insecure group permissions.\n")
                    else:
                        log_file.write(f"WARNING: {cron_file} has insecure permissions.\n")
                else:
                    log_file.write(f"WARNING: {cron_file} is not owned by root.\n")

        log_file.write("※ U-22 결과 : 양호(Good)\n")

    with open(tmp1, "r") as file:
        print(file.read())

check_crontab_permissions()
