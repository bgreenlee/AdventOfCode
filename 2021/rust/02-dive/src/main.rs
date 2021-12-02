use std::io::{self, Read};

enum Movement {
    Forward,
    Down,
    Up,
    Unknown,
}

struct Command {
    movement: Movement,
    distance: i32,
}

impl Command {
    fn new(record_str : &str) -> Command {
        let parts : Vec<&str> = record_str
            .split(|c:char| !c.is_alphanumeric())
            .filter(|c| !c.is_empty())
            .collect();

        let movement = match parts[0] {
            "forward" => Movement::Forward,
            "down" => Movement::Down,
            "up" => Movement::Up,
            _ => Movement::Unknown,
        };

        let distance = parts[1].parse().unwrap_or(0);
        Command { movement, distance }
    }
}

fn part1(commands: &Vec<Command>) {
    let mut pos = 0;
    let mut depth = 0;
    for command in commands {
        match command.movement {
            Movement::Forward => pos += command.distance,
            Movement::Down => depth += command.distance,
            Movement::Up => depth -= command.distance,
            _ => (),
        }
    }

    println!("Part 1 - pos: {}, depth: {}, total: {}", pos, depth, pos * depth);
}

fn part2(commands: &Vec<Command>) {
    let mut pos = 0;
    let mut depth = 0;
    let mut aim = 0;
    for command in commands {
        match command.movement {
            Movement::Forward => {
                pos += command.distance;
                depth += aim * command.distance;
            },
            Movement::Down => aim += command.distance,
            Movement::Up => aim -= command.distance,
            _ => (),
        }
    }

    println!("Part 2 - pos: {}, depth: {}, total: {}", pos, depth, pos * depth);
}

fn main() -> io::Result<()>  {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer)?;
    let commands = buffer.lines()
        .map(Command::new)
        .collect();

    part1(&commands);
    part2(&commands);

    Ok(())
}