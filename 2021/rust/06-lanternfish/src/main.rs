use std::io::{self, Read};

fn main() {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer).expect("Error reading from stdin");
    let fishes: Vec<usize> = buffer.split(",").map(|n| n.trim().parse::<usize>().unwrap_or(0)).collect();

    // initialize an array with the counts of fish at each age
    let mut counts: [u64; 9] = [0; 9];
    for fish in fishes {
        counts[fish] += 1;
    }

    println!("Part 1: {}", calculate_population(counts, 80));
    println!("Part 2: {}", calculate_population(counts, 256));
}

// given an array with counts of fish at each age, run a simulation for the
// given number of days, and then return the total number of fish
fn calculate_population(mut counts: [u64; 9], days: i32) -> u64 {
    for _ in 0..days {
        let new_fish = counts[0]; // fish at 0 create new fish
        // age the fish by moving them down one slot in our array
        for i in 0..8 {
            counts[i] = counts[i+1];
        }
        counts[8] = new_fish; // welcome, new fish!
        counts[6] += new_fish; // fish formerly at 0 are now at 6
    }
    return counts.iter().sum();
}
