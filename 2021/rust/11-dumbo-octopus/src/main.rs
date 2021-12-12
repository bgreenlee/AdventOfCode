use std::io::{self, Read};

fn main() {
    let mut buffer = String::new();
    io::stdin()
        .read_to_string(&mut buffer)
        .expect("Error reading from stdin");
    let lines: Vec<&str> = buffer.lines().collect();
    let height = lines.len();
    let width = lines[0].len();
    let mut map: Vec<Vec<u8>> = vec![vec![0; width]; height];

    for y in 0..height {
        for (x, c) in lines[y].char_indices() {
            map[y][x] = c.to_digit(10).unwrap() as u8;
        }
    }

    let mut total_flashes = 0;
    let mut step = 0;
    'steps: loop {
        step += 1;
        // increase everyone by one
        for y in 0..height {
            for x in 0..width {
                map[y][x] += 1
            }
        }
        
        'flashes: loop {
            let mut flash_count = 0;
            for y in 0..height {
                for x in 0..width {
                    if map[y][x] > 9 {
                        map[y][x] = 0;
                        flash_count += 1;
                        let neighbor_offsets: [(i32,i32); 8] = [
                            (-1,-1), (0,-1), (1,-1),
                            (-1, 0),         (1, 0),
                            (-1, 1), (0, 1), (1, 1)
                        ];
                        for offset in neighbor_offsets {
                            let nx = x as i32 + offset.0;
                            let ny = y as i32 + offset.1;
                            if nx >= 0 && ny >= 0 && nx <= width as i32 -1 && ny <= height as i32 -1 {
                                if map[ny as usize][nx as usize] != 0 {
                                    map[ny as usize][nx as usize] += 1;
                                }
                            }
                        }
                    }
                }
            }
            if flash_count == 0 {
                break 'flashes;
            }

            // see if we're at all zeros
            let mut all_zeros = true;
            'zero_check: for y in 0..height {
                for x in 0..width {
                    if map[y][x] != 0 {
                        all_zeros = false;
                        break 'zero_check;
                    }
                }
            }
            if all_zeros {
                break 'steps;
            }
            if step <= 100 {
                total_flashes += flash_count;
            }
        }
    }
    println!("Part 1: {}", total_flashes);
    println!("Part 2: {}", step);
}
