//! Test-branch-only harness: same logic as main.rs with injectable inputs.
//! Usage: harness <sendmail.cf_path|MISSING> <log_path>
#[path = "../main.rs"]
mod srv;

use std::path::Path;

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let config = if args[1] == "MISSING" {
        None
    } else {
        Some(std::fs::read_to_string(&args[1]).unwrap_or_default())
    };
    let stdout = std::io::stdout();
    match srv::run(config.as_deref(), Path::new(&args[2]), &mut stdout.lock()) {
        Ok(true) => {}
        Ok(false) => {
            eprintln!("SRV-006: 잘못된 LogLevel 값");
            std::process::exit(1);
        }
        Err(error) => {
            eprintln!("{error}");
            std::process::exit(1);
        }
    }
}
