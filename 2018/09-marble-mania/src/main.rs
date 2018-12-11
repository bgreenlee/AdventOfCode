use std::env;
use std::process::exit;

fn main() {
    if env::args().len() < 3 {
        println!("Usage: marble-mania <num_players> <last_marble_value>");
        exit(1);
    }

    let num_players = env::args().nth(1).unwrap()
        .parse::<i32>().expect("Could not parse input.");
    let last_marble_value = env::args().nth(2).unwrap()
        .parse::<i32>().expect("Could not parse input.");

    let mut circle : Vec<i32> = Vec::new();
    let mut current_marble_idx : i32 = 0;
    let mut player_scores = vec![0; num_players as usize];

    circle.push(0);

    for current_marble_value in 1..=last_marble_value {
        if current_marble_value % 23 != 0 {
            let next_marble_idx = ((current_marble_idx + 1) % circle.len() as i32) + 1;
            if next_marble_idx == circle.len() as i32 {
                circle.push(current_marble_value);
            } else {
                circle.insert(next_marble_idx as usize, current_marble_value);
            }
            current_marble_idx = next_marble_idx;
        } else {
            let player_num = current_marble_value % num_players;
            player_scores[player_num as usize] += current_marble_value;
            let bonus_marble_idx : i32 = (current_marble_idx - 7 + circle.len() as i32) % circle.len() as i32;
            let bonus_marble = circle.remove(bonus_marble_idx as usize);
            player_scores[player_num as usize] += bonus_marble;
            current_marble_idx = bonus_marble_idx;
        }
    }

    println!("scores: {:?}", player_scores);
    let top_score = player_scores.iter().max().unwrap_or(&0);
    println!("top score: {}", top_score);
}
