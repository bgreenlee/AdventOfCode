use regex::Regex;
use std::collections::HashSet;
use std::io::{self, Read};

fn main() {
    let mut buffer = String::new();
    io::stdin()
        .read_to_string(&mut buffer)
        .expect("Error reading from stdin");
    let lines: Vec<&str> = buffer.lines().collect();

    let mut map: HashSet<(i32, i32)> = HashSet::new();
    let mut folds: Vec<(char, i32)> = Vec::new();

    // parse our input
    let point_re = Regex::new(r"^(\d+),(\d+)$").unwrap();
    let fold_re = Regex::new(r"^fold along ([xy])=(\d+)$").unwrap();
    for line in lines {
        match point_re.captures(line) {
            Some(c) => {
                let x = c[1].parse().unwrap();
                let y = c[2].parse().unwrap();
                map.insert((x, y));
            }
            None => match fold_re.captures(line) {
                Some(c) => {
                    let axis = c[1].chars().nth(0).unwrap();
                    let value = c[2].parse().unwrap();
                    folds.push((axis, value));
                }
                None => {}
            },
        }
    }

    // start folding
    for (axis, value) in folds {
        let mut points: Vec<(i32, i32)> = map.into_iter().collect();
        for point in points.iter_mut() {
            match *point {
                (x, y) if axis == 'x' && x > value => *point = (2 * value - x, y),
                (x, y) if axis == 'y' && y > value => *point = (x, 2 * value - y),
                _ => {},
            }
        }
        map = points.into_iter().collect();
        println!("fold {:?} => {}", (axis, value), map.len());
    }

    // get max x and y
    let mut max_x = 0;
    let mut max_y = 0;
    for (x, y) in map.iter() {
        if *x > max_x {
            max_x = *x
        }
        if *y > max_y {
            max_y = *y
        }
    }

    // display
    for y in 0..=max_y {
        for x in 0..=max_x {
            let char = if map.contains(&(x, y)) { "#" } else { " " };
            print!("{}", char);
        }
        println!();
    }
}
