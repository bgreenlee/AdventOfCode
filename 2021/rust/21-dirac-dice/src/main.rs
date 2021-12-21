fn main() {
    part1(4, 7);
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

#[allow(unused_macros)]
macro_rules! dbg {
    ($x:expr) => {
        println!("{} = {:?}",stringify!($x),$x);
    }
}
