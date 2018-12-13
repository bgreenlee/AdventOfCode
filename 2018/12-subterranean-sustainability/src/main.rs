use std::io::{self, Read};

fn pots_to_int(pots: &Vec<char>) -> i32 {
    pots.iter().enumerate().map(|(i, &c)| {
        if c == '#' { 2_i32.pow(4 - i as u32 ) } else { 0 }
    }).sum()
}

fn pots_to_str(pots: &Vec<char>) -> String {
    pots.iter().collect()
}

fn main() {
    let padding = vec!['.','.','.'];
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer).expect("Error reading from stdin");
    let lines : Vec<&str> = buffer.lines().collect();
    let pots_str = format!("...{}...", lines[0].trim_start_matches("initial state: "));
    let mut pots : Vec<char> = pots_str.chars().collect();
    let mut transforms = [0; 32];
    (&lines[2..]).iter().map(|&t| {
        let parts : Vec<&str> = (*t).split(" => ").collect();
        let pots_vec : Vec<char> = parts[0].chars().collect();
        let val = pots_to_int(&pots_vec);
        (val, if parts[1].chars().nth(0).unwrap() == '#' { 1 } else { 0 })
    }).for_each(|(i, v)| transforms[i as usize] = v);

    println!("0: {}", pots_to_str(&pots));
    let mut last_sum = 0;
    let mut last_diff = 0;
    let mut generation = 1;
    loop {
        let mut next_gen= vec!['.','.'];
        for i in 2..pots.len() - 2 {
            let section = (&pots[i - 2..=i + 2]).to_vec();
            let section_val = pots_to_int(&section);
            let pot_state= if transforms[section_val as usize] == 1 { '#' } else { '.' };
        //    println!("{:?} => {} => {}", section, section_val, pot_state);
            next_gen.push(pot_state);
        }
        next_gen.append(&mut padding.clone());
        pots = next_gen;
        //println!("{}: {}", generation, pots_to_str(&pots));
        let sum : i32 = pots.iter().enumerate().map(|(i, &c)| if c == '#' { i as i32 - 3 } else { 0 }).sum();
        println!("{}: {} ({})", generation, sum, sum - last_sum);
        if sum - last_sum == last_diff {
            break;
        }
        last_diff = sum - last_sum;
        last_sum = sum;
        generation += 1;
    }

    let answer = last_sum as i64 + (50000000000 - generation as i64 + 1) * last_diff as i64;
    println!("answer: {}", answer);

//    let sum : i32 = pots.iter().enumerate().map(|(i, &c)| if c == '#' { i as i32 - 3 } else { 0 }).sum();
//    println!("{}: {}", generation, sum);
//    println!("{:?}", pots);
//    println!("{:?}", transforms);
}
