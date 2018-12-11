use std::env;
use std::process::exit;
use std::collections::VecDeque;

fn main() {
    if env::args().len() < 3 {
        println!("Usage: marble-mania <num_players> <last_marble_value>");
        exit(1);
    }

    let num_players = env::args().nth(1).unwrap()
        .parse::<i64>().expect("Could not parse input.");
    let last_marble_value = env::args().nth(2).unwrap()
        .parse::<i64>().expect("Could not parse input.");

    let mut circle : VecDeque<i64> = VecDeque::with_capacity(last_marble_value as usize);
    let mut current_marble_idx : i64 = 0;
    let mut player_scores = vec![0; num_players as usize];

    circle.push_back(0);
    let mut circle_len : i64 = 1;

    for current_marble_value in 1..=last_marble_value {
        if current_marble_value % 23 != 0 {
            let next_marble_idx = ((current_marble_idx + 1) % circle_len) + 1;
            if next_marble_idx == circle_len {
                circle.push_back(current_marble_value);
            } else {
                circle.insert(next_marble_idx as usize, current_marble_value);
            }
            circle_len += 1;
            current_marble_idx = next_marble_idx;
        } else {
            let player_num = current_marble_value % num_players;
            player_scores[player_num as usize] += current_marble_value;
            let bonus_marble_idx : i64 = (current_marble_idx - 7 + circle_len) % circle_len;
            let bonus_marble = circle.remove(bonus_marble_idx as usize).unwrap();
            circle_len -= 1;
            player_scores[player_num as usize] += bonus_marble;
            current_marble_idx = bonus_marble_idx;
        }
        let pct_done = (current_marble_value as f64 / last_marble_value as f64) * 100.0;
        if current_marble_value % (last_marble_value / 100) == 0 {
            println!("{:.*}%", 0, pct_done);
        }
    }

    let top_score = player_scores.iter().max().unwrap_or(&0);
    println!("top score: {}", top_score);
}
