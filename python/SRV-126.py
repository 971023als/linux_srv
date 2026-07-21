import os

# 결과 파일 초기화
script_name = "SCRIPTNAME.log"  # 실제 스크립트 이름으로 변경해야 합니다.

def write_result(message):
    with open(script_name, 'a') as f:
        f.write(message + "\n")

def check_autologin_for_gdm():
    gdm_config_file = "/etc/gdm3/custom.conf"
    if os.path.exists(gdm_config_file):
        with open(gdm_config_file, 'r') as file:
            if "AutomaticLoginEnable=false" in file.read():
                write_result("GDM에서 자동 로그온이 비활성화되어 있습니다.")
            else:
                write_result("GDM에서 자동 로그온이 활성화되어 있습니다.")
    else:
        write_result("GDM 설정 파일이 존재하지 않습니다.")

def check_autologin_for_lightdm():
    lightdm_config_file = "/etc/lightdm/lightdm.conf"
    if os.path.exists(lightdm_config_file):
        with open(lightdm_config_file, 'r') as file:
            if "autologin-user=" in file.read():
                write_result("LightDM에서 자동 로그온이 설정되어 있습니다.")
            else:
                write_result("LightDM에서 자동 로그온이 비활성화되어 있습니다.")
    else:
        write_result("LightDM 설정 파일이 존재하지 않습니다.")

def main():
    open(script_name, 'w').close()  # 결과 파일 초기화
    check_autologin_for_gdm()
    check_autologin_for_lightdm()

if __name__ == "__main__":
    main()
