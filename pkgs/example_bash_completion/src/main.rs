use clap::{Parser, Subcommand, CommandFactory};

#[derive(Parser)]
#[command(name="example")]
struct CLI {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    Status,
    Other,
    Completions {
        shell: clap_complete::Shell
    },
}

fn main() {
    match CLI::parse().command {
        Commands::Status => {
            println!("Hello, world!");
            println!("Status Command");
        },
        Commands::Other => {
            println!("Hello, world!");
            println!("Other Command");
        },
        Commands::Completions{shell} => {
            clap_complete::generate(shell, &mut CLI::command(), "example", &mut std::io::stdout() );
        },
    }
}
