use std::io::{self, Read};
use std::{fmt,env};
use std::collections::HashMap;
use regex::Regex;

#[derive(Debug,Eq,PartialEq,Copy,Clone)]
enum Cell {
    Sand,
    Clay,
    Spring,
    Stream,
    Water,
}

#[derive(Debug,Eq,PartialEq)]
struct Game {
    cells: HashMap<(usize,usize),Cell>,
    min_y: usize,
    max_y: usize,
}

impl fmt::Display for Game {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let mut output = String::new();
        let min_x = self.cells.keys().map(|k| k.0).min().unwrap();
        let max_x = self.cells.keys().map(|k| k.0).max().unwrap();

        for y in 0..=self.max_y {
            for x in min_x..=max_x {
                output.push(match self.cell_at(&(x,y)) {
                    Cell::Sand   => ' ',
                    Cell::Clay   => '#',
                    Cell::Spring => '+',
                    Cell::Stream => '|',
                    Cell::Water  => '~',
                })
            }
            output.push('\n');
        }

        write!(f, "{}", output)
    }
}

impl Game {
    fn from_string(input: &str) -> Game {
        let mut cells = HashMap::new();
        let re = Regex::new(r"([xy])=(\d+), [xy]=(\d+)\.\.(\d+)").unwrap();
        for line in input.lines() {
            let caps = re.captures(line).unwrap();
            let point = caps[2].parse::<usize>().unwrap();
            let range = (caps[3].parse::<usize>().unwrap(), caps[4].parse::<usize>().unwrap());
            if &caps[1] == "x" {
                for y in range.0..=range.1 {
                    cells.insert((point, y), Cell::Clay);
                }
            } else {
                for x in range.0..=range.1 {
                    cells.insert((x, point), Cell::Clay);
                }
            }
        }
        let min_y = 1; //cells.keys().map(|k| k.1).min().unwrap();
        let max_y = cells.keys().map(|k| k.1).max().unwrap();

        cells.insert((500,0), Cell::Spring);

        Game { cells, min_y, max_y }
    }

    fn cell_at(&self, location: &(usize, usize)) -> Cell {
        match self.cells.get(&location) {
            Some(&cell) => cell.clone(),
            None => Cell::Sand
        }
    }

    fn cell_in_bounds(&self, location: &(usize, usize)) -> bool {
        location.1 >= self.min_y && location.1 <= self.max_y
    }

    fn water_count(&self) -> (usize, usize) {
        let stream_count = self.cells.values()
            .filter(|&&c| c == Cell::Stream)
            .collect::<Vec<_>>()
            .len();
        let water_count = self.cells.values()
            .filter(|&&c| c == Cell::Water)
            .collect::<Vec<_>>()
            .len();
        (stream_count, water_count)
    }

    fn advance(&mut self) {
        let mut next_cells = self.cells.clone();
        for (location, _cell) in &self.cells {
            let left = (location.0-1, location.1);
            let right = (location.0+1, location.1);
            let down = (location.0, location.1+1);
            let cell_left = self.cell_at(&left);
            let cell_right = self.cell_at(&right);
            let cell_down = self.cell_at(&down);

            match self.cell_at(&location) {
                Cell::Spring => {
                    next_cells.insert(down, Cell::Stream);
                },
                Cell::Stream => {
                    if self.cell_in_bounds(&down) {
                        match cell_down {
                            Cell::Sand => {
                                next_cells.insert(down, Cell::Stream);
                            },
                            _ => (),
                        };
                    }

                    match cell_left {
                        Cell::Sand if (cell_down == Cell::Water || cell_down == Cell::Clay) => {
                            next_cells.insert(left, Cell::Stream);
                        },
                        Cell::Water => {
                            next_cells.insert( *location, Cell::Water);
                        },
                        Cell::Clay => {
                            // turn to water if the stream is trapped to the right
                            let mut is_trapped = false;
                            let mut x = location.0+1;
                            loop {
                                match self.cell_at(&(x, location.1)) {
                                    Cell::Sand => {
                                        break;
                                    },
                                    Cell::Clay => {
                                        is_trapped = true;
                                        break;
                                    }
                                    _ => (),
                                }
                                x += 1;
                            }
                            if is_trapped {
                                next_cells.insert(*location, Cell::Water);
                            }
                        },
                        _ => (),
                    };

                    match cell_right {
                        Cell::Sand if (cell_down == Cell::Water || cell_down == Cell::Clay) => {
                            next_cells.insert(right, Cell::Stream);
                        },
                        Cell::Water => {
                            next_cells.insert( *location, Cell::Water);
                        },
                        Cell::Clay => {
                            // turn to water if the stream is trapped to the left
                            let mut is_trapped = false;
                            let mut x = location.0-1;
                            loop {
                                match self.cell_at(&(x, location.1)) {
                                    Cell::Sand => {
                                        break;
                                    },
                                    Cell::Clay => {
                                        is_trapped = true;
                                        break;
                                    }
                                    _ => (),
                                }
                                x -= 1;
                            }
                            if is_trapped {
                                next_cells.insert(*location, Cell::Water);
                            }
                        },
                        _ => (),
                    };

                },
                Cell::Water => {
                    match cell_left {
                        Cell::Sand => {
                            next_cells.insert(left, Cell::Water);
                        },
                        _ => (),
                    };
                    match cell_right {
                        Cell::Sand => {
                            next_cells.insert(right, Cell::Water);
                        },
                        _ => (),
                    };
                },
                _ => (),
            }
        }
        self.cells = next_cells;
    }
}

fn main() {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer).expect("Error reading from stdin");
    let steps = env::args().nth(1).unwrap_or("0".to_string()).parse::<i32>().expect("could not parse input!");
    let mut game = Game::from_string(&buffer);
    let mut last_water_count = (0,0);
    let mut round = 0;
    loop {
        game.advance();
        let water_count = game.water_count();
        if steps == 0 {
            if water_count == last_water_count {
                break;
            }
            last_water_count = water_count;

            if round % 1000 == 0 {
                println!("Round {}:\n{}", round, game);
            }
        } else {
            if round >= steps {
                break;
            }
        }
        round += 1;
    }
    println!("{}", game);
    println!("Water count: {}", last_water_count.0 + last_water_count.1);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_from_string() {
        let input= "x=495, y=2..7
y=7, x=495..501
x=501, y=3..7
x=498, y=2..4
x=506, y=1..2
x=498, y=10..13
x=504, y=10..13
y=13, x=498..504";

        let game = Game::from_string(input);
        assert_eq!(game.cell_at(&(500,0)), Cell::Spring);
        assert_eq!(game.cell_at(&(501,3)), Cell::Clay);
        assert_eq!(game.cell_at(&(495,7)), Cell::Clay);
        assert_eq!(game.cell_at(&(0,0)), Cell::Sand);
        assert_eq!(game.min_y, 1);
        assert_eq!(game.max_y, 13);
        assert_eq!(game.cell_in_bounds(&(494,0)), false);
        assert_eq!(game.cell_in_bounds(&(491,1)), true);
    }
}