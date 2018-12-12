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
    let mut high_coord = (0,0);
    for y in 0..grid.len()-3 {
        for x in 0..grid[y].len()-3 {
            let block_total =
                grid[y][x]   + grid[y][x+1]   + grid[y][x+2] +
                grid[y+1][x] + grid[y+1][x+1] + grid[y+1][x+2] +
                grid[y+2][x] + grid[y+2][x+1] + grid[y+2][x+2];
            if block_total > high_power {
                high_power = block_total;
                high_coord = (x+1, y+1);
            }
        }
    }

    println!("{:?} => {}", high_coord, high_power);
}
