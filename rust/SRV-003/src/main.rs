//! Additive Rust pilot for python/SRV-003.py. No external crates.
//! Preserves the original Korean messages, write_log append semantics
//! (one newline added per entry), the truncate-then-append log file
//! (SRV-003.py.log), and the three separator lines printed before the log dump.
//! UTF-8 only; error text differs from Python traceback output.
use std::fs;
use std::io::{self, Write};
use std::path::Path;
use std::process::Command;

const BAR: &str = "--------------------------------------------------";

/// Equivalent of `ps -ef | grep -i 'snmp' | grep -v 'grep' | wc -l` > 0:
/// case-insensitive "snmp" match, lines containing case-sensitive "grep" excluded.
pub fn snmp_service_running(ps_output: &str) -> bool {
    ps_output
        .lines()
        .filter(|line| line.to_lowercase().contains("snmp") && !line.contains("grep"))
        .count()
        > 0
}

pub fn check_snmp_configuration(snmpdconf_path: &Path) -> io::Result<String> {
    match fs::read_to_string(snmpdconf_path) {
        Ok(contents) => {
            let hit = contents.lines().any(|line| {
                let lower = line.to_lowercase();
                lower.contains("rouser") || lower.contains("rwuser")
            });
            Ok(if hit {
                "WARN: SNMP 접근 제어 설정이 불충분함".to_string()
            } else {
                "OK: SNMP 접근 제어 설정이 적절함".to_string()
            })
        }
        Err(error) if error.kind() == io::ErrorKind::NotFound => Ok(format!(
            "WARN: SNMP 구성 파일({})을 찾을 수 없음",
            snmpdconf_path.display()
        )),
        Err(error) => Err(error),
    }
}

/// Python write_log: appends the message plus one newline.
fn write_log(log: &mut String, message: &str) {
    log.push_str(message);
    log.push('\n');
}

pub fn run(
    ps_output: &str,
    snmpdconf_path: &Path,
    log_path: &Path,
    output: &mut impl Write,
) -> io::Result<()> {
    let mut log = String::new();
    write_log(&mut log, "CODE [SRV-003] SNMP 접근 통제 설정 오류\n");
    write_log(&mut log, "[양호]: 적절한 SNMP 접근 통제 설정이 적용된 경우\n[취약]: SNMP 접근 통제 설정이 불충분한 경우\n");
    write_log(&mut log, "[SRV-003] SNMP 접근 통제 설정 오류");
    if snmp_service_running(ps_output) {
        let result = check_snmp_configuration(snmpdconf_path)?;
        write_log(&mut log, &result);
    } else {
        write_log(&mut log, "OK: SNMP 서비스가 실행 중이지 않습니다.");
    }
    // Python truncates the log first, then appends each entry.
    fs::write(log_path, &log)?;
    // Python prints bar() three times to stdout, then the whole log via print().
    writeln!(output, "{BAR}")?;
    writeln!(output, "{BAR}")?;
    writeln!(output, "{BAR}")?;
    // print() appends its own newline after the log text.
    writeln!(output, "{log}")?;
    Ok(())
}

fn main() {
    // subprocess.getoutput() yields "" on failure, which counts as not running.
    let ps_output = Command::new("ps")
        .arg("-ef")
        .output()
        .map(|out| String::from_utf8_lossy(&out.stdout).into_owned())
        .unwrap_or_default();
    let stdout = io::stdout();
    if let Err(error) = run(
        &ps_output,
        Path::new("/etc/snmp/snmpd.conf"),
        Path::new("SRV-003.py.log"),
        &mut stdout.lock(),
    ) {
        eprintln!("SRV-003: {error}");
        std::process::exit(1);
    }
}
