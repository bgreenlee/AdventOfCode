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

// cribbed from Moishe's recursive version
// https://github.com/Moishe/aoc-21/blob/main/day-21/part-2.py
fn part2(p1: u8, p2: u8) {
    // number of times out of three rolls that each index comes up (3 = 1/27, 4 = 3/27, etc.)
    static ROLL_OUTCOMES: [u8; 10] = [0, 0, 0, 1, 3, 6, 7, 6, 3, 1];

    let mut wins: [u64; 2] = [0, 0];
    let mut stack: Vec<(usize, [u8; 2], [u8; 2], u64)> = vec![(0, [p1, p2], [0, 0], 1)];

    while !stack.is_empty() {
        let (player, positions, scores, outcomes) = stack.pop().unwrap();

        for roll in 3..=9 {
            let new_pos = (positions[player] + roll - 1) % 10 + 1;
            let new_score = scores[player] + new_pos;
            let (new_positions, new_scores) = match player {
                0 => ([new_pos, positions[1]], [new_score, scores[1]]),
                _ => ([positions[0], new_pos], [scores[0], new_score])
            };

            let outcomes = outcomes * ROLL_OUTCOMES[roll as usize] as u64;
            if new_scores[player] >= 21 {
                wins[player] += outcomes;
            } else {
                stack.push(((player + 1) % 2, new_positions, new_scores, outcomes));
            }
        }
    }

    println!("Part 2:");
    println!("  Player 1: {}", wins[0]);
    println!("  Player 2: {}", wins[1]);
}

#[allow(unused_macros)]
macro_rules! dbg {
    ($x:expr) => {
        println!("{} = {:?}", stringify!($x), $x);
    };
}
