#!/bin/bash

# Source the function script
. function.sh

# Initialize CSV file
CSV_FILE=$(basename "$0").csv
echo "Category,Code,Risk Level,Diagnosis Item,DiagnosisResult,Status" > $CSV_FILE

# Function to append results to CSV file
append_to_csv() {
  local category=$1
  local code=$2
  local risk_level=$3
  local diagnosis_item=$4
  local diagnosis_result=$5
  local status=$6
  echo "$category,$code,$risk_level,$diagnosis_item,$diagnosis_result,$status" >> $CSV_FILE
}

BAR

# Set diagnostic variables
category="시스템 보안"
code="SRV-139"
riskLevel="높음"
diagnosisItem="시스템 자원 소유권 변경 권한 설정"
diagnosisResult=""
status=""

# Append security criteria to the result file
result=$(basename "$0").log
> $result

cat << EOF >> $result
[양호]: 중요 시스템 자원의 소유권 변경 권한이 제한되어 있는 경우
[취약]: 중요 시스템 자원의 소유권 변경 권한이 제한되어 있지 않은 경우
EOF

BAR

# Function to check file ownership and permissions
check_permissions() {
  local file=$1
  local owner=$2
  local permission_limit=$3
  local owner_perms=$4
  local group_perms=$5
  local other_perms=$6
  local result_message=$7
  local diagnosis_result=""

  if [ -f $file ]; then
    local file_owner=$(ls -l $file | awk '{print $3}')
    if [[ $file_owner =~ $owner ]]; then
      local file_permission=$(stat -c %a $file)
      if [ $file_permission -le $permission_limit ]; then
        local owner_permission=${file_permission:0:1}
        local group_permission=${file_permission:1:1}
        local other_permission=${file_permission:2:1}
        
        if [[ $owner_perms =~ $owner_permission ]] && [[ $group_perms =~ $group_permission ]] && [[ $other_perms =~ $other_permission ]]; then
          diagnosis_result="양호"
          OK "※ $result_message 결과 : 양호(Good)" >> $result
        else
          diagnosis_result="취약"
          WARN " $file 파일의 권한이 취약합니다." >> $result
        fi
      else
        diagnosis_result="취약"
        WARN " $file 파일의 권한이 $permission_limit 보다 큽니다." >> $result
      fi
    else
      diagnosis_result="취약"
      WARN " $file 파일의 소유자(owner)가 $owner 가 아닙니다." >> $result
    fi
  else
    diagnosis_result="파일 없음"
    WARN " $file 파일이 없습니다." >> $result
  fi

  append_to_csv "$category" "$code" "$riskLevel" "$result_message" "$diagnosis_result" "$diagnosis_result"
}

# Check /etc/passwd
check_permissions "/etc/passwd" "root" 644 "0|2|4|6" "0|4" "0|4" "U-07"

# Check /etc/shadow
check_permissions "/etc/shadow" "root" 400 "0|4" "0" "0" "U-08"

# Check /etc/hosts
check_permissions "/etc/hosts" "root" 600 "0|2|4|6" "0" "0" "U-09"

# Check /etc/xinetd.conf and /etc/inetd.conf
file_exists_count=0
check_permissions "/etc/xinetd.conf" "root" 600 "6" "0" "0" "U-10"
if [ -f /etc/xinetd.conf ]; then ((file_exists_count++)); fi
check_permissions "/etc/inetd.conf" "root" 600 "6" "0" "0" "U-10"
if [ -f /etc/inetd.conf ]; then ((file_exists_count++)); fi
if [ $file_exists_count -eq 0 ]; then 
  INFO " /etc/(x)inetd.conf 파일이 없습니다." >> $result
  append_to_csv "$category" "$code" "$riskLevel" "U-10" "파일 없음" "파일 없음"
fi

# Check syslog configuration files
syslogconf_files=("/etc/rsyslog.conf" "/etc/syslog.conf" "/etc/syslog-ng.conf")
file_exists_count=0
for file in "${syslogconf_files[@]}"; do
  check_permissions "$file" "root|bin|sys" 640 "6|4|2|0" "4|2|0" "0" "U-11"
  if [ -f $file ]; then ((file_exists_count++)); fi
done
if [ $file_exists_count -eq 0 ]; then 
  INFO " /etc/syslog.conf 파일이 없습니다." >> $result
  append_to_csv "$category" "$code" "$riskLevel" "U-11" "파일 없음" "파일 없음"
fi

# Check /etc/services
check_permissions "/etc/services" "root|bin|sys" 644 "6|4|2|0" "4|0" "4|0" "U-12"

# Check user home directory start files
user_homedirectory_path=($(awk -F : '$7!="/bin/false" && $7!="/sbin/nologin" && $6!=null {print $6}' /etc/passwd))
user_homedirectory_path2=(/home/*)
user_homedirectory_path+=("${user_homedirectory_path2[@]}")
user_homedirectory_owner_name=($(awk -F : '$7!="/bin/false" && $7!="/sbin/nologin" && $6!=null {print $1}' /etc/passwd))
user_homedirectory_owner_name2=()
for path in "${user_homedirectory_path2[@]}"; do
  user_homedirectory_owner_name2+=($(basename $path))
done
user_homedirectory_owner_name+=("${user_homedirectory_owner_name2[@]}")

start_files=(".profile" ".cshrc" ".login" ".kshrc" ".bash_profile" ".bashrc" ".bash_login")
for ((i=0; i<${#user_homedirectory_path[@]}; i++)); do
  for start_file in "${start_files[@]}"; do
    if [ -f ${user_homedirectory_path[$i]}/$start_file ]; then
      check_permissions "${user_homedirectory_path[$i]}/$start_file" "root|${user_homedirectory_owner_name[$i]}" 600 "6|4|2|0" "4|0" "0" "U-14"
    fi
  done
done

# Check r commands in /etc/xinetd.d
r_command=("rsh" "rlogin" "rexec" "shell" "login" "exec")
if [ -d /etc/xinetd.d ]; then
  for cmd in "${r_command[@]}"; do
    if [ -f /etc/xinetd.d/$cmd ]; then
      check_permissions "/etc/xinetd.d/$cmd" "root" 600 "6|4|2|0" "0" "0" "U-17"
    fi
  done
fi

# Check crontab files and directories
crontab_path=("/usr/bin/crontab" "/usr/sbin/crontab" "/bin/crontab")
crontab_path+=($(which crontab 2>/dev/null))
for path in "${crontab_path[@]}"; do
  check_permissions "$path" "root" 750 "7|5|4|1|0" "5|4|1|0" "0" "U-22"
done
cron_directory=("/etc/cron.hourly" "/etc/cron.daily" "/etc/cron.weekly" "/etc/cron.monthly" "/var/spool/cron" "/var/spool/cron/crontabs")
cron_file=("/etc/crontab" "/etc/cron.allow" "/etc/cron.deny")
for dir in "${cron_directory[@]}"; do
  cron_files=$(find $dir -type f 2>/dev/null)
  for file in $cron_files; do
    cron_file+=($file)
  done
done
for file in "${cron_file[@]}"; do
  check_permissions "$file" "root" 640 "6|4|2|0" "4|0" "0" "U-22"
done

# Check ftpusers files
ftpusers_files=("/etc/ftpusers" "/etc/pure-ftpd/ftpusers" "/etc/wu-ftpd/ftpusers" "/etc/vsftpd/ftpusers" "/etc/proftpd/ftpusers" "/etc/ftpd/ftpusers" "/etc/vsftpd.ftpusers" "/etc/vsftpd.user_list" "/etc/vsftpd/user_list")
file_exists_count=0
for file in "${ftpusers_files[@]}"; do
  check_permissions "$file" "root" 640 "6|4|2|0" "4|0" "0" "U-63"
  if [ -f $file ]; then ((file_exists_count++)); fi
done
if [ $file_exists_count -eq 0 ]; then 
  INFO " ftp 접근제어 파일이 없습니다." >> $result
  append_to_csv "$category" "$code" "$riskLevel" "U-63" "파일 없음" "파일 없음"
fi

# Check PATH settings
path=($(echo $PATH | tr ':' ' '))
for user_path in "${user_homedirectory_path[@]}"; do
  for file in "${start_files[@]}"; do
    if [ -f $user_path/$file ]; then
      user_paths=$(grep -i 'PATH' $user_path/$file | awk -F \" '{print $2}' | tr ':' ' ')
      for p in $user_paths; do
        if [[ $p != \$PATH ]]; then
          if [[ $p == \$HOME* ]]; then
            p=$(echo $p | sed "s|\$HOME|$user_path|")
          fi
          path+=($p)
        fi
      done
    fi
  done
done
for p in "${path[@]}"; do
  if [ -f $p/at ]; then
    check_permissions "$p/at" "root" 750 "7|5|4|1|0" "5|4|1|0" "0" "U-65"
  fi
done
at_access_control_files=("/etc/at.allow" "/etc/at.deny")
for file in "${at_access_control_files[@]}"; do
  check_permissions "$file" "root" 640 "6|4|2|0" "4|0" "0" "U-65"
done

# Check /etc/exports
check_permissions "/etc/exports" "root" 644 "6|4|2|0" "4|0" "4|0" "U-69"

# Display the results
cat $result

# Print newlines
echo; echo
