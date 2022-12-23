// gow-status - a CLI tool to get the running status of GOW oriented images
// His very first Rust application built by Ian Sorbello, Dec 2022.
// Q: This app doesn't do very much, why didn't you just write a short shell script?
// A: (1) I wanted to learn Rust, and (2) I always seem to do things the hard way.

use clap::{command, Arg, ArgAction, ArgMatches};
use dockworker::{container::ContainerFilters, Docker};
use dotenv::dotenv;
use serde::{Deserialize, Serialize};
use std::{collections::HashMap, env, panic};

const SUNSHINE_CONTAINER_NAME: &str = "SUNSHINE_CONTAINER_NAME";

#[derive(Serialize, Deserialize)]
struct AllResults {
    verbosity: bool,
    sunshine_container: SunshineContainer,
}

#[derive(Serialize, Deserialize)]
struct SunshineContainer {
    is_running: bool,
}

fn main() {
    // Process the command line
    let cli = process_cli();

    // Process the environment
    let env_vars = get_env_vars();

    let final_inputs = process_inputs(&cli, &env_vars);

    // Get the status of the sunshine container
    let sunshine_container_result = query_sunshine(
        final_inputs
            .get(&SUNSHINE_CONTAINER_NAME.to_string())
            .unwrap(),
    );

    // Wrap it all up
    let all_results = AllResults {
        sunshine_container: sunshine_container_result,
        verbosity: cli.get_flag("verbose"),
    };

    // Process all the output
    if cli.get_flag("json") {
        process_json(&all_results);
    } else {
        process_text(&all_results);
    }
}

fn process_text(results: &AllResults) {
    println!("gow-status - querying all the things...");
    println!("---------------------------------------");
    println!("");
    if results.verbosity {
        println!("Verbosity ON")
    };
    println!(
        "Sunshine is {}",
        if results.sunshine_container.is_running {
            "RUNNING"
        } else {
            "NOT RUNNING"
        }
    );
}

fn process_json(results: &AllResults) {
    print!("{}", serde_json::to_string(results).unwrap());
}

fn process_inputs(cli: &ArgMatches, env_vars: &HashMap<String, String>) -> HashMap<String, String> {
    let mut input_data: HashMap<String, String> = env_vars.clone();

    // We need the sunshine container name to hunt for docker running state.
    // First, is this on the cli? (this overrides the environment)
    let env_args = cli
        .get_many::<String>("env")
        .unwrap_or_default()
        .map(|v| v.as_str())
        .collect::<Vec<_>>();

    for s in env_args.iter() {
        // Must be a key=value format, split on the =
        let split = s.split('=').collect::<Vec<_>>();
        if split.len() == 2 {
            // Looks like format is OK, lock it in
            let k = split[0];
            let v = split[1];

            if k.eq(&SUNSHINE_CONTAINER_NAME.to_string()) {
                input_data.insert(k.to_string(), v.to_string());
            }
        }
    }

    // Do we have the SUNSHINE_CONTAINER_NAME defined?
    if !input_data.contains_key(&SUNSHINE_CONTAINER_NAME.to_string()) {
        panic!("Environment variable $SUNSHINE_CONTAINER_NAME is not defined. Set this with an export, add to a .env file next to this exe, or pass in the command line with --env SUNSHINE_CONTAINER_NAME=<value>");
    }

    return input_data;
}

fn process_cli() -> ArgMatches {
    let cli = command!()
        .arg(
            Arg::new("verbose")
                .short('v')
                .long("verbose")
                .action(ArgAction::SetTrue),
        )
        .arg(
            Arg::new("json")
                .short('j')
                .long("json")
                .help("output as a json structure (good for IPC if that's your jam)")
                .action(ArgAction::SetTrue),
        )
        .arg(
            Arg::new("env")
                .short('e')
                .long("env")
                .help("You can provide multiple key=value inputs")
                .action(ArgAction::Append),
        )
        .get_matches();

    return cli;
}

// Collate all our environment vars here
// Could come from the environment, a .env file, or from the command line (in that order)
fn get_env_vars() -> HashMap<String, String> {
    dotenv().ok();
    let mut env_data: HashMap<String, String> = HashMap::new();

    match std::env::var(SUNSHINE_CONTAINER_NAME) {
        Ok(val) => {
            env_data.insert(SUNSHINE_CONTAINER_NAME.to_string(), val);
        }
        _ => {}
    }

    return env_data;
}

fn query_sunshine(container_name: &String) -> SunshineContainer {
    let docker = Docker::connect_with_defaults().unwrap();
    let filter = ContainerFilters::new();
    let containers = docker.list_containers(None, None, None, filter);
    let mut is_running: bool = false;

    containers.iter().for_each(|_c| {
        if _c.len() > 0 {
            if _c[0].Image.eq(container_name) {
                is_running = _c[0].State.eq(&"running".to_string());
            }
        }
    });

    let sc = SunshineContainer {
        is_running: is_running,
    };
    return sc;
}
