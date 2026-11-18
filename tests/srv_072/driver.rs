#[allow(dead_code)]
#[path = "pilot_source.rs"]
mod pilot;
fn main() {
    let args: Vec<String> = std::env::args().collect();
    if let Err(e) = pilot::run(std::path::Path::new(&args[1]), std::path::Path::new(&args[2]), &mut std::io::stdout()) {
        eprintln!("SRV-072: {e}");
        std::process::exit(1);
    }
}
