fn main() {
    part1(4, 7);
    part2(4, 7);
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

fn part2(p1: u8, p2: u8) {
    let mut wins: [u64; 2] = [0, 0];
    split_universe(&mut wins, 0, [p1,p2], [0,0], 1);
    println!("Part 2:");
    println!("  Player 1: {}", wins[0]);
    println!("  Player 2: {}", wins[1]);
}

// cribbed from Moishe
// https://github.com/Moishe/aoc-21/blob/main/day-21/part-2.py
fn split_universe(wins: &mut [u64; 2], player: usize, positions: [u8; 2], scores: [u8; 2], instances: u64) {
    // number of times out of three rolls that each index comes up (3 = 1/27, 4 = 3/27, etc.)
    static ROLL_OUTCOMES: [u8; 10] = [0, 0, 0, 1, 3, 6, 7, 6, 3, 1];

    for roll in 3..=9 {
        let new_positions;
        let new_scores;
        let new_pos = (positions[player] + roll - 1) % 10 + 1;
        let new_score = scores[player] + new_pos;
        if player == 0 {
            new_positions = [new_pos, positions[1]];
            new_scores = [new_score, scores[1]];
        } else {
            new_positions = [positions[0], new_pos];
            new_scores = [scores[0], new_score];
        }

        if new_scores[player] >= 21 {
            wins[player] += instances * ROLL_OUTCOMES[roll as usize] as u64;
        } else {
            split_universe(wins, (player + 1) % 2, new_positions, new_scores, instances * ROLL_OUTCOMES[roll as usize] as u64);
        }
    }
}

#[allow(unused_macros)]
macro_rules! dbg {
    ($x:expr) => {
        println!("{} = {:?}",stringify!($x),$x);
    }
}
