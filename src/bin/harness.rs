//! Test-branch-only harness: same logic as main.rs with injectable inputs.
//! Usage: harness <ps_fixture_file> <snmpd.conf_path> <log_path>
#[path = "../main.rs"]
mod srv;

use std::path::Path;

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let ps_output = std::fs::read_to_string(&args[1]).unwrap_or_default();
    let stdout = std::io::stdout();
    if let Err(error) = srv::run(
        &ps_output,
        Path::new(&args[2]),
        Path::new(&args[3]),
        &mut stdout.lock(),
    ) {
        eprintln!("{error}");
        std::process::exit(1);
    }
}
