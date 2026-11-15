//! Test-branch-only harness: same logic as main.rs with injectable inputs.
//! Usage: harness <sendmail.cf_path|MISSING> <main.cf_path|MISSING> <log_path>
#[path = "../main.rs"]
mod srv;

use std::path::Path;

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let read = |a: &str| {
        if a == "MISSING" {
            None
        } else {
            Some(std::fs::read_to_string(a).unwrap_or_default())
        }
    };
    let sendmail = read(&args[1]);
    let postfix = read(&args[2]);
    let stdout = std::io::stdout();
    if let Err(error) = srv::run(
        sendmail.as_deref(),
        postfix.as_deref(),
        Path::new(&args[3]),
        &mut stdout.lock(),
    ) {
        eprintln!("{error}");
        std::process::exit(1);
    }
}
