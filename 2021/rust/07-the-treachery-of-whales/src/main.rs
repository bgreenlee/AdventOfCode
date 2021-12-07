use std::io::{self, Read};

fn main() {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer)
        .expect("Error reading from stdin");
    let mut positions: Vec<i32> = buffer.split(",")
        .map(|n| n.trim().parse::<i32>().unwrap_or(0))
        .collect();
    positions.sort();

    println!("Brute force:");
    brute_force(&positions);

    println!("\nMedian and mean:");
    median_and_mean(&positions);
}

fn brute_force(positions: &[i32]) {
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

// via https://www.reddit.com/r/adventofcode/comments/rawxad/2021_day_7_part_2_i_wrote_a_paper_on_todays/
fn median_and_mean(positions: &[i32]) {
    let median = positions[positions.len()/2];
    let mean: f32 = positions.iter().sum::<i32>() as f32 / positions.len() as f32;

    // part 1
    let score = positions.iter()
        .fold(0, |acc, p| acc + (p - median as i32).abs());
    println!("Part 1: {}", score);

    // part 2
    let score = (0..=1).map(|i|
        positions.iter()
            .fold(0, |acc, p| {
                let diff = (p - (mean + i as f32 - 0.5) as i32).abs();
                return acc + diff * (diff + 1) / 2;
            })
        )
        .min()
        .unwrap();
    println!("Part 2: {}", score);
}