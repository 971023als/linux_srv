//! Additive Rust pilot for python/SRV-008.py. No external crates.
//! Preserves the original Korean messages, the 32-'=' separator lines, the
//! truncate-then-append log file (SRV-008.py.log), the Python regex semantics
//! for both config formats, and the final log dump to stdout. UTF-8 only;
//! error text differs from Python traceback output.
use std::fs;
use std::io::{self, Write};
use std::path::Path;

const BAR: &str = "================================";

const SENDMAIL_SETTINGS: [&str; 5] = [
    "MaxDaemonChildren",
    "ConnectionRateThrottle",
    "MinFreeBlocks",
    "MaxHeadersLength",
    "MaxMessageSize",
];

const POSTFIX_SETTINGS: [&str; 5] = [
    "message_size_limit",
    "header_size_limit",
    "default_process_limit",
    "local_destination_concurrency_limit",
    "smtpd_recipient_limit",
];

/// Python re.search(rf"^O\s*{setting}=", content, re.MULTILINE).
/// The 'O' must start a line; \s* may cross newlines; '=' must follow the
/// setting name immediately.
pub fn sendmail_has(content: &str, setting: &str) -> bool {
    let bytes = content.as_bytes();
    let target = format!("{setting}=");
    for (i, &b) in bytes.iter().enumerate() {
        if b == b'O' && (i == 0 || bytes[i - 1] == b'\n') {
            let mut j = i + 1;
            while j < bytes.len() && (bytes[j] as char).is_whitespace() {
                j += 1;
            }
            if content[j..].starts_with(&target) {
                return true;
            }
        }
    }
    false
}

/// Python: any(re.match(rf"^{setting}\s*=", line) for line in lines).
/// The line must start with the setting name; whitespace then '='.
pub fn postfix_has(content: &str, setting: &str) -> bool {
    content.lines().any(|line| {
        match line.strip_prefix(setting) {
            Some(rest) => rest
                .trim_start_matches(|c: char| c.is_whitespace())
                .starts_with('='),
            None => false,
        }
    })
}

pub fn run(
    sendmail: Option<&str>,
    postfix: Option<&str>,
    log_path: &Path,
    output: &mut impl Write,
) -> io::Result<()> {
    let mut log = String::new();
    let mut w = |s: &str| {
        log.push_str(s);
        log.push('\n');
    };
    w(BAR);
    w("[SRV-008] SMTP 서비스의 DoS 방지 기능 미설정");
    w("[양호]: SMTP 서비스에 DoS 방지 설정이 적용된 경우");
    w("[취약]: SMTP 서비스에 DoS 방지 설정이 적용되지 않은 경우");
    w(BAR);
    w("Sendmail DoS 방지 설정을 점검 중입니다...");
    match sendmail {
        Some(content) => {
            for setting in SENDMAIL_SETTINGS {
                if sendmail_has(content, setting) {
                    w(&format!("OK: {setting} 설정이 적용되었습니다."));
                } else {
                    w(&format!("WARN: {setting} 설정이 적용되지 않았습니다."));
                }
            }
        }
        None => w("INFO: Sendmail 설정 파일이 존재하지 않습니다."),
    }
    w("Postfix DoS 방지 설정을 점검 중입니다...");
    match postfix {
        Some(content) => {
            for setting in POSTFIX_SETTINGS {
                if postfix_has(content, setting) {
                    w(&format!("OK: {setting} 설정이 적용되었습니다."));
                } else {
                    w(&format!(
                        "WARN: {setting} 설정이 명시적으로 구성되지 않았습니다(기본값 사용 가능)."
                    ));
                }
            }
        }
        None => w("INFO: Postfix 설정 파일이 존재하지 않습니다."),
    }
    w(BAR);
    // Python truncates the log first, then appends each entry.
    fs::write(log_path, &log)?;
    // print(f.read()) appends one newline after the log text.
    writeln!(output, "{log}")?;
    Ok(())
}

fn main() {
    let read_optional = |path: &str| match fs::read_to_string(path) {
        Ok(content) => Some(content),
        Err(error) if error.kind() == io::ErrorKind::NotFound => None,
        Err(error) => {
            eprintln!("SRV-008: {error}");
            std::process::exit(1);
        }
    };
    let sendmail = read_optional("/etc/mail/sendmail.cf");
    let postfix = read_optional("/etc/postfix/main.cf");
    let stdout = io::stdout();
    if let Err(error) = run(
        sendmail.as_deref(),
        postfix.as_deref(),
        Path::new("SRV-008.py.log"),
        &mut stdout.lock(),
    ) {
        eprintln!("SRV-008: {error}");
        std::process::exit(1);
    }
}
