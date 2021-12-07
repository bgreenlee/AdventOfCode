use std::io::{self, Read};

fn main() {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer)
        .expect("Error reading from stdin");
    let mut positions: Vec<i32> = buffer.split(",")
        .map(|n| n.trim().parse::<i32>().unwrap_or(0))
        .collect();
    positions.sort();

    let first = *positions.first().unwrap();
    let last = *positions.last().unwrap();

    // part 1
    let score = (first..=last).map(|i| 
            positions.iter()
                .fold(0, |acc, p| acc + (p - i).abs())
        )
        .min()
        .unwrap();
    println!("Part 1: {}", score);

    // part 2
    let score = (first..=last).map(|i|
            positions.iter()
                .fold(0, |acc, p| acc + (p - i).abs() * ((p - i).abs() + 1) / 2 )
        )
        .min()
        .unwrap();

    println!("Part 2: {}", score);
}

