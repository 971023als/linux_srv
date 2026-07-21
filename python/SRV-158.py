import subprocess

def check_telnet_ftp_services():
    # Telnet 및 FTP 포트 사용 여부 확인
    telnet_ports = subprocess.getoutput("grep -vE '^#|^\\s#' /etc/services | awk 'tolower($1)==\"telnet\" {print $2}' | awk -F '/' 'tolower($2)==\"tcp\" {print $1}'").split()
    ftp_ports = subprocess.getoutput("grep -vE '^#|^\\s#' /etc/services | awk 'tolower($1)==\"ftp\" {print $2}' | awk -F '/' 'tolower($2)==\"tcp\" {print $1}'").split()

    # Telnet 및 FTP 서비스 실행 여부 확인
    for port in telnet_ports + ftp_ports:
        if subprocess.getoutput(f"netstat -nat | grep -w 'tcp' | grep -Ei 'listen|established|syn_sent|syn_received' | grep \":{port} \""):
            print(f"WARN: 서비스가 실행 중입니다. 포트: {port}")
            return

    # vsftpd.conf 및 proftpd.conf 파일에서 포트 설정 검사
    for conf_file in ('vsftpd.conf', 'proftpd.conf'):
        conf_files = subprocess.getoutput(f"find / -name '{conf_file}' -type f 2>/dev/null").split('\n')
        for file_path in conf_files:
            if conf_file == 'vsftpd.conf':
                conf_ports = subprocess.getoutput(f"grep -vE '^#|^\\s#' {file_path} | grep 'listen_port' | awk -F '=' '{{gsub(\" \", \"\", $0); print $2}}'").split()
            else:  # proftpd.conf
                conf_ports = subprocess.getoutput(f"grep -vE '^#|^\\s#' {file_path} | grep 'Port' | awk '{{print $2}}'").split()

            for port in conf_ports:
                if subprocess.getoutput(f"netstat -nat | grep -w 'tcp' | grep -Ei 'listen|established|syn_sent|syn_received' | grep \":{port} \""):
                    print(f"WARN: {conf_file} 서비스가 실행 중입니다. 포트: {port}")
                    return

    # Telnet 및 FTP 프로세스 실행 여부 확인
    for service in ('telnet', 'ftp'):
        if subprocess.getoutput(f"ps -ef | grep -i '{service}' | grep -v 'grep'"):
            print(f"WARN: {service.capitalize()} 서비스가 실행 중입니다.")
            return

    print("OK: Telnet 및 FTP 서비스가 비활성화되어 있습니다.")

if __name__ == "__main__":
    check_telnet_ftp_services()
