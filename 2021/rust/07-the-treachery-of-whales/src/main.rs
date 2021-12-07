use std::io::{self, Read};

fn main() {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer)
        .expect("Error reading from stdin");
    let positions: Vec<i32> = buffer.split(",")
        .map(|n| n.trim().parse::<i32>().unwrap_or(0))
        .collect();

    // part 1
    let mut min_score: i32 = i32::MAX;
    for position in &positions {
        let score = positions.iter()
            .fold(0, |acc, p| acc + (p - position).abs());
        if score < min_score {
            min_score = score;
        }
    }
    println!("Part 1: {}", min_score);

    // part 2
    min_score = i32::MAX;
    for position in &positions {
        let score = positions.iter()
            .fold(0, |acc, p| {
                let dist = (p - position).abs();
                return acc + dist * (dist + 1) / 2;
            });
        if score < min_score {
            min_score = score;
        }
    }
    println!("Part 2: {}", min_score);
}

