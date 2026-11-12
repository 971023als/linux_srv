//! Additive Rust pilot for python/SRV-072.py. No external crates.
//! Preserves the original case-sensitive substring search, append-only log,
//! and printing of the entire accumulated log. This is not account-field parsing.
//! UTF-8 only; error text differs from Python traceback output.
use std::fs::{self, OpenOptions};
use std::io::{self, Write};
use std::path::Path;

pub fn run(passwd_path: &Path, log_path: &Path, output: &mut impl Write) -> io::Result<()> {
    let message = match fs::read_to_string(passwd_path) {
        Ok(contents) => {
            if contents.contains("Administrator") {
                "기본 'Administrator' 계정이 존재합니다."
            } else {
                "기본 'Administrator' 계정이 존재하지 않습니다."
            }
        }
        Err(error) if error.kind() == io::ErrorKind::NotFound => {
            "파일을 찾을 수 없습니다: /etc/passwd"
        }
        Err(error) => return Err(error),
    };
    {
        let mut log = OpenOptions::new().create(true).append(true).open(log_path)?;
        writeln!(log, "{message}")?;
    }
    // Python text-mode reads normalize universal newlines before print().
    let contents = fs::read_to_string(log_path)?.replace("\r\n", "\n").replace('\r', "\n");
    writeln!(output, "{contents}")
}

fn main() {
    let stdout = io::stdout();
    if let Err(error) = run(
        Path::new("/etc/passwd"),
        Path::new("administrator_account_check.log"),
        &mut stdout.lock(),
    ) {
        eprintln!("SRV-072: {error}");
        std::process::exit(1);
    }
}
