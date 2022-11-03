# CFD Learning Project in RUST
*Description and Goals coming soon*

## Project Organization:
- `matlab/`: contains MATLAB files for quick prototyping and visualization
- `hello_cargo/`: contains the [Rust/Cargo Hello World](https://doc.rust-lang.org/book/ch01-03-hello-cargo.html) example

More information on `rust` project structures can be found [here](https://doc.rust-lang.org/cargo/guide/project-layout.html)

## Building Project (WSL/Ubuntu):
1. Ensure that `cargo` is installed (can test with `cargo --version`).  If not, install using `sudo apt install cargo -y`.  (It may be necessary to first run: `sudo apt-get update; sudo apt-get upgrade -y; sudo apt update; sudo apt upgrade -y`)
2. `cd` into the project to build (e.g., `cd hello_cargo`)
3. Build the project using `cargo build` from within the project directory.  (Alternatively, to build the project and immediately run it, you can use `cargo run`)