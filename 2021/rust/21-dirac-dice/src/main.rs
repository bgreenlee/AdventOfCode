fn main() {
    part1(4, 7);
    part2(4, 8);
}

fn part1(p1: u32, p2: u32) {
    let mut pos = [p1, p2];
    let mut score = [0, 0];
    let mut die = 1;
    let answer;

    'outer: loop {
        for p in 0..2 {
            let roll = (die - 1) % 100 + die % 100 + (die + 1) % 100 + 3;
            pos[p] = (pos[p] + roll - 1) % 10 + 1;
            score[p] += pos[p];
            die += 3;
    
            if score[p] >= 1000 {
                answer = score[1 - p] * (die - 1);
                break 'outer;
            }    
        }
    }

    println!("Part 1: {}", answer);
}

fn part2(p1: u32, p2: u32) {
    let start_pos = [p1, p2];

    // number of times out of three rolls that each index comes up (3 = 1/27, 4 = 3/27, etc.)
    let roll_outcomes = [
        (3, 1),
        (4, 3),
        (5, 6),
        (6, 7),
        (7, 6),
        (8, 3),
        (9, 1),
    ];

    // positions & outcomes for each round, per player
    let mut rounds: [Vec<Vec<(u32,u32,u64)>>; 2] = [Vec::new(), Vec::new()];

    // pre-populate the first round
    // println!("round 1:");
    for player in 0..2 {
        let mut pos_scores: Vec<(u32,u32,u64)> = Vec::new();
        // println!("  player {}:", player+1);
        for (roll, outcomes) in roll_outcomes.into_iter() {
            let pos = (start_pos[player] + roll - 1) % 10 + 1;
            pos_scores.push((pos, pos, outcomes));
            // println!("    ({}, {}, {})", pos, pos, outcomes);
        }
        rounds[player].push(pos_scores);
    }

    // do the remaining rounds; after each roll we check for a winner
    let mut wins: [u64; 2] = [0, 0];
    for round in 1..10 {
        // println!("round {}:", round+1);
        for player in 0..2 {
            if &rounds[player].len() < &round {
                break; // player is done
            }
            // println!("  player {}:", player+1);
            // for each of the outcomes of the last round, run through all the possible outcomes for this round
            let mut pos_scores: Vec<(u32,u32,u64)> = Vec::new();
            for (last_pos, last_score, last_outcomes) in &rounds[player][round-1] {
                for (roll, outcomes) in roll_outcomes.into_iter() {
                    let pos = (last_pos + roll - 1) % 10 + 1;
                    let score = last_score + pos;
                    let num_outcomes = last_outcomes * outcomes;
                    if score >= 21 {
                        wins[player] += num_outcomes;
                    } else {
                        // println!("    ({}, {}, {})", pos, score, num_outcomes);
                        pos_scores.push((pos, score, num_outcomes));
                    }
                }
            }
            println!("round {} player {} scores {}", round, player + 1, pos_scores.len());
            if !pos_scores.is_empty() {
                rounds[player].push(pos_scores);
            }
        }
        println!("Round {}: p1 = {}, p2 = {}", round, wins[0], wins[1]);
    }
}


#[allow(unused_macros)]
macro_rules! dbg {
    ($x:expr) => {
        println!("{} = {:?}",stringify!($x),$x);
    }
}
