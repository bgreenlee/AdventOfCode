use std::env;
use std::process::exit;

fn main() {
    if env::args().len() < 2 {
        println!("Usage: chronal-charge <serial_number>");
        exit(1);
    }

    let serial_num = env::args().nth(1).unwrap()
        .parse::<i64>().expect("Could not parse input.");
    let mut grid = [[0; 300]; 300];

    for y in 0..grid.len() {
        for x in 0..grid[y].len() {
            let rack_id = (x + 11) as i64;
            let power_level = rack_id * (y+1) as i64 + serial_num;
            let power_level = power_level * rack_id;
            let power_level = (power_level / 100) % 10 - 5;
            grid[y][x] = power_level;
        }
    }

    let mut high_power = i64::min_value();
    let mut high_coord = (0,0,0);
    for s in 0..grid.len() {
        println!("{}", s+1);
        for y in 0..grid.len() - s {
            for x in 0..grid[y].len() - s {
                let mut block_total = 0;
                for by in y..=y+s {
                    for bx in x..=x+s {
                        block_total += grid[by][bx];
                    }
                }
                if block_total > high_power {
                    high_power = block_total;
                    high_coord = (x + 1, y + 1, s + 1);
                }
            }
        }
    }

    println!("{:?} => {}", high_coord, high_power);
}
