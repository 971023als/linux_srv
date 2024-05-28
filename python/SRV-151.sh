import subprocess
import os

def check_anonymous_sid_name_translation():
    try:
        # 보안 정책 파일 내보내기
        export_command = 'secpol.exe /export /cfg secpol.cfg'
        subprocess.check_call(export_command, shell=True)
        
        # 파일이 제대로 생성되었는지 확인
        if os.path.isfile('secpol.cfg'):
            with open('secpol.cfg', 'r') as file:
                content = file.read()
                # 익명 SID/이름 변환 정책 확인
                if "SeDenyNetworkLogonRight = *S-1-1-0" in content:
                    print("양호: 익명 SID/이름 변환을 허용하지 않습니다.")
                else:
                    print("취약: 익명 SID/이름 변환을 허용합니다.")
            os.remove('secpol.cfg')  # 정책 파일 삭제
        else:
            print("경고: 보안 정책 파일을 추출할 수 없습니다.")
    
    except subprocess.CalledProcessError as e:
        print(f"보안 정책 파일 추출 중 오류 발생: {e}")

if __name__ == "__main__":
    check_anonymous_sid_name_translation()
