use std::io::{self, Read};
use std::collections::HashSet;

type Point = (usize, usize);

fn main() {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer)
        .expect("Error reading from stdin");
    let lines: Vec<&str> = buffer.lines().collect();

    let mut map = Map::new(&lines);
    println!("Part 1: {}", map.solve());
}

struct Map {
    easties: HashSet<Point>,
    southies: HashSet<Point>,
    height: usize,
    width: usize,
}

impl Map {
    fn new(lines: &Vec<&str>) -> Self {
        let mut easties = HashSet::<Point>::new();
        let mut southies = HashSet::<Point>::new();
        let height = lines.len();
        let width = lines[0].len();
        for y in 0..height {
            for (x, c) in lines[y].char_indices() {
                match c {
                    '>' => { easties.insert((x,y)); },
                    'v' => { southies.insert((x,y)); },
                    _ => {},
                }
            }
        }
        Self { easties, southies, height, width }
    }

    #[allow(dead_code)]
    fn display(&self) {
        for y in 0..self.height {
            for x in 0..self.width {
                if self.easties.contains(&(x,y)) {
                    print!(">");
                } else if self.southies.contains(&(x,y)) {
                    print!("v");
                } else {
                    print!(".");
                }
            }
            println!();
        }
        println!();
    }

    fn solve(&mut self) -> usize {
        let mut step = 0;
        let mut somebody_moved = true;
        while somebody_moved {
            somebody_moved = false;
            // move easties
            let mut new_easties = HashSet::<Point>::new();
            for (x,y) in &self.easties {
                let next_point = ((x + 1) % self.width, *y);
                if self.easties.contains(&next_point) || self.southies.contains(&next_point) {
                    new_easties.insert((*x,*y));
                    continue;
                }
                new_easties.insert(next_point);
                somebody_moved = true;
            }
            self.easties = new_easties;
    
            // move southies
            let mut new_southies = HashSet::<Point>::new();
            for (x,y) in &self.southies {
                let next_point = (*x, (y + 1) % self.height);
                if self.southies.contains(&next_point) || self.easties.contains(&next_point) {
                    new_southies.insert((*x,*y));
                    continue;
                }
                new_southies.insert(next_point);
                somebody_moved = true;
            }
            self.southies = new_southies;
            step += 1; 
            // display(&easties, &southies);
        }
        step
    }
}
