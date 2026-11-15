//! Additive Rust pilot for python/SRV-004.py. No external crates.
//! Preserves the original Korean messages, the truncate-then-print log file
//! (SRV-004.py.log), the 50-dash separator lines, and the final log dump to
//! stdout. UTF-8 only; error text differs from Python traceback output.
use std::fs;
use std::io::{self, Write};
use std::path::Path;
use std::process::Command;

const BAR: &str = "--------------------------------------------------";

/// systemctl is-active --quiet postfix: exit code 0 means active.
pub fn service_status_message(service_active: bool) -> String {
    if service_active {
        "WARN: postfix 서비스가 실행 중입니다.".to_string()
    } else {
        "OK: postfix 서비스가 비활성화되어 있거나 실행 중이지 않습니다.".to_string()
    }
}

/// Python: f":{port} " in `ss -tuln` output (trailing space required).
pub fn port_open(ss_output: &str, port: u16) -> bool {
    ss_output.contains(&format!(":{port} "))
}

pub fn port_status_message(ss_output: &str) -> String {
    if port_open(ss_output, 25) {
        "WARN: SMTP 포트(25)가 열려 있습니다. 불필요한 서비스가 실행 중일 수 있습니다.".to_string()
    } else {
        "OK: SMTP 포트(25)는 닫혀 있습니다.".to_string()
    }
}

pub fn run(
    service_active: bool,
    ss_output: &str,
    log_path: &Path,
    output: &mut impl Write,
) -> io::Result<()> {
    let mut log = String::new();
    let mut w = |s: &str| {
        log.push_str(s);
        log.push('\n');
    };
    w(BAR);
    w("CODE [SRV-004] 불필요한 SMTP 서비스 실행");
    w("[양호]: SMTP 서비스가 비활성화되어 있거나 필요한 경우에만 실행되는 경우\n[취약]: SMTP 서비스가 필요하지 않음에도 실행되고 있는 경우");
    w(BAR);
    w("[SRV-004] 불필요한 SMTP 서비스 실행");
    w(&service_status_message(service_active));
    w(&port_status_message(ss_output));
    w(BAR);
    // Python writes the log with one newline per print(), then closes it.
    fs::write(log_path, &log)?;
    // print(log_file.read()) appends one newline after the log text.
    writeln!(output, "{log}")?;
    Ok(())
}

fn main() {
    let status = match Command::new("systemctl")
        .args(["is-active", "--quiet", "postfix"])
        .stdout(std::process::Stdio::null())
        .status()
    {
        Ok(status) => status,
        Err(error) => {
            eprintln!("SRV-004: systemctl 실행 실패: {error}");
            std::process::exit(1);
        }
    };
    let ss_output = match Command::new("ss").arg("-tuln").output() {
        Ok(out) => String::from_utf8_lossy(&out.stdout).into_owned(),
        Err(error) => {
            eprintln!("SRV-004: ss 실행 실패: {error}");
            std::process::exit(1);
        }
    };
    let stdout = io::stdout();
    if let Err(error) = run(
        status.success(),
        &ss_output,
        Path::new("SRV-004.py.log"),
        &mut stdout.lock(),
    ) {
        eprintln!("SRV-004: {error}");
        std::process::exit(1);
    }
}
