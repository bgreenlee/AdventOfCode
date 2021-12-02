# Advent of Code 2021 - Rust Solutions

## Setup

Start a new day with `cargo new --name <project-name> <day number>-<project-name>`.
E.g.: `cargo new --name sonar-sweep 01-sonar-sweep`

Run with `cat input.dat | cargo run`

## Quickstart Development

Here's a program that will read from stdin and output an array of lines:

```
use std::io::{self, Read};

fn main() -> io::Result<()>  {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer)?;

    for line in buffer.lines() {
      println!("{}", line);
    }

    Ok(())
}
```

