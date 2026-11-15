//! Additive Rust pilot for python/SRV-006.py. No external crates.
//! Preserves the original Korean messages, the 40-'=' separator lines, the
//! quoted title line, the truncate-then-append log file (SRV-006.py.log), and
//! the final log dump to stdout. On an unparseable LogLevel token the Python
//! original dies with a traceback (exit 1, partial log kept); this port writes
//! the same partial log, prints a short error to stderr instead, and exits 1.
//! UTF-8 only.
use std::fs;
use std::io::{self, Write};
use std::path::Path;

const BAR: &str = "========================================";

pub enum Eval {
    Msg(String),
    /// Python raises IndexError/ValueError on a malformed "O LogLevel" line.
    Crash,
}

/// check_log_level_setting on the sendmail.cf content (None = file missing).
pub fn evaluate(config: Option<&str>) -> Eval {
    match config {
        None => Eval::Msg(
            "INFO: sendmail 구성 파일(/etc/mail/sendmail.cf)을 찾을 수 없습니다.".to_string(),
        ),
        Some(content) => {
            for line in content.lines() {
                if line.starts_with("O LogLevel") {
                    // Python: line.strip().split()[2] -> IndexError if absent
                    let Some(token) = line.split_whitespace().nth(2) else {
                        return Eval::Crash;
                    };
                    // Python: int(token) -> ValueError if not numeric
                    return match token.parse::<i64>() {
                        Ok(value) if value >= 9 => Eval::Msg(format!(
                            "OK: SMTP 서비스의 로그 수준이 적절하게 설정됨 (현재 수준: {token})."
                        )),
                        Ok(_) => Eval::Msg(format!(
                            "WARN: SMTP 서비스의 로그 수준이 낮게 설정됨 (현재 수준: {token})."
                        )),
                        Err(_) => Eval::Crash,
                    };
                }
            }
            Eval::Msg(
                "WARN: SMTP 서비스의 로그 수준이 낮게 설정됨 (현재 수준: 미설정).".to_string(),
            )
        }
    }
}

/// Returns Ok(true) when the run completed, Ok(false) when it mirrored the
/// Python crash path (partial log written, caller exits 1).
pub fn run(
    config: Option<&str>,
    log_path: &Path,
    output: &mut impl Write,
) -> io::Result<bool> {
    let mut log = String::new();
    let mut w = |s: &str| {
        log.push_str(s);
        log.push('\n');
    };
    w(BAR);
    w("CODE [SRV-006] SMTP 서비스 로그 수준 설정 미흡");
    w("[양호]: SMTP 서비스의 로그 수준이 적절하게 설정되어 있는 경우\n[취약]: SMTP 서비스의 로그 수준이 낮거나, 로그가 충분히 수집되지 않는 경우");
    w(BAR);
    w("\"[SRV-006] SMTP 서비스 로그 수준 설정 미흡\"");
    match evaluate(config) {
        Eval::Crash => {
            // The original dies before logging the result and before the
            // final bar and stdout dump.
            fs::write(log_path, &log)?;
            Ok(false)
        }
        Eval::Msg(message) => {
            w(&message);
            w(BAR);
            fs::write(log_path, &log)?;
            // print(log_file.read()) appends one newline after the log text.
            writeln!(output, "{log}")?;
            Ok(true)
        }
    }
}

fn main() {
    let config = match fs::read_to_string("/etc/mail/sendmail.cf") {
        Ok(content) => Some(content),
        Err(error) if error.kind() == io::ErrorKind::NotFound => None,
        Err(error) => {
            eprintln!("SRV-006: {error}");
            std::process::exit(1);
        }
    };
    let stdout = io::stdout();
    match run(
        config.as_deref(),
        Path::new("SRV-006.py.log"),
        &mut stdout.lock(),
    ) {
        Ok(true) => {}
        Ok(false) => {
            eprintln!("SRV-006: 잘못된 LogLevel 값");
            std::process::exit(1);
        }
        Err(error) => {
            eprintln!("SRV-006: {error}");
            std::process::exit(1);
        }
    }
}
