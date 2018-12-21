use std::io::{self, Read};
use std::collections::{HashMap, HashSet};
use termion::{color, style, clear, cursor};
use std::fmt;

#[derive(Clone,Eq,PartialEq)]
enum Cell {
    Open, Trees, Lumberyard, Unknown
}

#[derive(Clone)]
struct Board {
    cells: HashMap<(usize,usize),Cell>,
    width: usize,
    height: usize,
}

impl fmt::Display for Board {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let mut output = String::new();
        let open = format!("{}.", color::Fg(color::LightGreen));
        let trees = format!("{}{}|{}", color::Fg(color::Green), style::Bold, style::Reset);
        let lumberyard = format!("{}#", color::Fg(color::Yellow));
        let unknown = "?";
        for y in 0..self.height {
            for x in 0..self.width {
                if let Some(cell) = self.cells.get(&(x,y)) {
                    output.push_str(match cell {
                        Cell::Open => &open,
                        Cell::Trees => &trees,
                        Cell::Lumberyard => &lumberyard,
                        Cell::Unknown => &unknown,
                    });
                }
            }
            output.push('\n');
        }

        write!(f, "{}", output)
    }
}

impl Board {
    fn from_string(input: &str) -> Board {
        let mut cells = HashMap::new();

        let mut x: usize = 0;
        let mut y: usize = 0;
        for line in input.lines() {
            x = 0;
            for char in line.chars() {
                let cell = match char {
                    '.' => Cell::Open,
                    '|' => Cell::Trees,
                    '#' => Cell::Lumberyard,
                    _   => Cell::Unknown,
                };
                cells.insert((x, y), cell);
                x += 1;
            }
            y += 1
        }
        Board { cells, width: x, height: y }
    }

    fn adjacent_cells(&self, location: &(usize, usize)) -> Vec<&Cell> {
        let mut adjacent = Vec::new();
        let (x, y) = *location;

        if y > 0 {
            adjacent.push(self.cells.get(&(x, y-1)).unwrap());
            if x < self.width - 1 {
                adjacent.push(self.cells.get(&(x+1, y-1)).unwrap());
            }
        }
        if x < self.width - 1 {
            adjacent.push(self.cells.get(&(x+1, y)).unwrap());
            if y < self.height - 1 {
                adjacent.push(self.cells.get(&(x+1, y+1)).unwrap());
            }
        }
        if y < self.height - 1 {
            adjacent.push(self.cells.get(&(x, y+1)).unwrap());
            if x > 0 {
                adjacent.push(self.cells.get(&(x-1, y+1)).unwrap());
            }
        }
        if x > 0 {
            adjacent.push(self.cells.get(&(x-1, y)).unwrap());
            if y > 0 {
                adjacent.push(self.cells.get(&(x-1, y-1)).unwrap());
            }
        }

        adjacent
    }

    fn num_adjacent(&self, location: &(usize, usize), cell: Cell) -> usize {
        self.adjacent_cells(location).iter()
            .filter(|c| ***c == cell)
            .collect::<Vec<_>>()
            .len()
    }

    fn advance(&mut self) {
        let mut next_cells = self.cells.clone();
        for (loc, cell) in &self.cells {
            match cell {
                Cell::Open if self.num_adjacent(loc, Cell::Trees) >= 3 => {
                    next_cells.insert(*loc, Cell::Trees);
                },
                Cell::Trees if self.num_adjacent( loc, Cell::Lumberyard) >= 3 => {
                    next_cells.insert(*loc, Cell::Lumberyard);
                },
                Cell::Lumberyard if self.num_adjacent(loc, Cell::Lumberyard) == 0 ||
                    self.num_adjacent(loc, Cell::Trees) == 0 => {
                    next_cells.insert(*loc, Cell::Open);
                },
                _ => (),
            }
        }
        self.cells = next_cells;
    }

    fn resource_value(&self) -> usize {
        let trees = &self.cells.values()
            .filter(|c| **c == Cell::Trees)
            .collect::<Vec<_>>()
            .len();
        let lumberyards = &self.cells.values()
            .filter(|c| **c == Cell::Lumberyard)
            .collect::<Vec<_>>()
            .len();

        trees * lumberyards
    }
}

fn main() {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer).expect("Error reading from stdin");

    let mut board = Board::from_string(&buffer);
    println!("{}", board);

    println!("{}", clear::All);

    let mut cycle_detector = HashMap::new();
    for i in 1..10000 {
        board.advance();
//        println!("{}{}:\n{}", cursor::Goto(1, 1), i, board);
        let value = board.resource_value();
        println!("{}: {}", i, value);
        if let Some(round) = cycle_detector.get(&value) {
            println!("...cycle detected, length = {}", i - round);
        }
        cycle_detector.insert(value, i);
    }

//    println!("Resource value: {}", board.resource_value());
}
