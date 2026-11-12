//! Additive Rust pilot for python/SRV-001.py. No external crates.
//! Preserves the original Korean messages, the truncate-and-rewrite log file
//! (SRV-001.py.log), the three separator lines printed before the log dump,
//! and the `ps -ef | grep -i snmp | grep -v grep | wc -l` service check.
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
            let weak = contents.lines().any(|line| {
                let lower = line.to_lowercase();
                lower.contains("public") || lower.contains("private")
            });
            Ok(if weak {
                "WARN: 기본 SNMP Community 스트링(public/private)이 사용됨".to_string()
            } else {
                "OK: 기본 SNMP Community 스트링(public/private)이 사용되지 않음".to_string()
            })
        }
        Err(error) if error.kind() == io::ErrorKind::NotFound => Ok(format!(
            "WARN: SNMP 구성 파일({})을 찾을 수 없음",
            snmpdconf_path.display()
        )),
        Err(error) => Err(error),
    }
}

pub fn run(
    ps_output: &str,
    snmpdconf_path: &Path,
    log_path: &Path,
    output: &mut impl Write,
) -> io::Result<()> {
    let mut log = String::new();
    log.push_str("CODE [SRV-001] SNMP 서비스 Get Community 스트링 설정 오류\n");
    log.push_str("\n[양호]: SNMP Community 스트링이 복잡하고 예측 불가능하게 설정된 경우\n");
    log.push_str("[취약]: SNMP Community 스트링이 기본값이거나 예측 가능하게 설정된 경우\n");
    log.push_str("\n[SRV-001] SNMP 서비스 Get Community 스트링 설정 오류\n");
    if snmp_service_running(ps_output) {
        let result = check_snmp_configuration(snmpdconf_path)?;
        log.push_str(&result);
        log.push('\n');
    } else {
        log.push_str("OK: SNMP 서비스가 실행 중이지 않습니다.\n");
    }
    // Python opens the log with 'w': truncate and rewrite each run.
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
        Path::new("SRV-001.py.log"),
        &mut stdout.lock(),
    ) {
        eprintln!("SRV-001: {error}");
        std::process::exit(1);
    }
}
