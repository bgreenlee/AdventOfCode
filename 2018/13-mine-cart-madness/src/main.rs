use std::io::{self, Read};
use std::collections::HashMap;

#[derive(Debug,PartialEq,Eq)]
enum Tile { Straight, CornerDown, CornerUp, Intersection, Empty, }
#[derive(Debug,PartialEq,Eq,Copy,Clone)]
enum Direction { Up, Down, Left, Right, }
#[derive(Debug,PartialEq,Eq,Copy,Clone)]
enum Turn { Left, Straight, Right, }

#[derive(Debug,PartialEq,Eq,Copy,Clone)]
struct Cart {
    location: (usize, usize),
    direction: Direction,
    next_turn: Turn,
    is_dead: bool,
}

impl Cart {
    fn new(c: char, location: (usize, usize)) -> Cart {
        let direction = match c {
            '^' => Direction::Up,
            'v' => Direction::Down,
            '<' => Direction::Left,
            '>' => Direction::Right,
            _ => panic!("Illegal cart character: {}", c),
        };
        Cart { location, direction, next_turn: Turn::Left, is_dead: false }
    }

    fn turn_at_intersection(&mut self) {
        let (direction, next_turn) = match (&self.direction, &self.next_turn)  {
            (Direction::Up, Turn::Left) => (Direction::Left, Turn::Straight),
            (Direction::Up, Turn::Straight) => (Direction::Up, Turn::Right),
            (Direction::Up, Turn::Right) => (Direction::Right, Turn::Left),
            (Direction::Down, Turn::Left) => (Direction::Right, Turn::Straight),
            (Direction::Down, Turn::Straight) => (Direction::Down, Turn::Right),
            (Direction::Down, Turn::Right) => (Direction::Left, Turn::Left),
            (Direction::Left, Turn::Left) => (Direction::Down, Turn::Straight),
            (Direction::Left, Turn::Straight) => (Direction::Left, Turn::Right),
            (Direction::Left, Turn::Right) => (Direction::Up, Turn::Left),
            (Direction::Right, Turn::Left) => (Direction::Up, Turn::Straight),
            (Direction::Right, Turn::Straight) => (Direction::Right, Turn::Right),
            (Direction::Right, Turn::Right) => (Direction::Down, Turn::Left),
        };
        self.direction = direction;
        self.next_turn = next_turn;
    }

    fn turn_at_corner(&mut self, tile: &Tile) {
        let new_direction = match (&mut self.direction, tile) {
            (Direction::Up, Tile::CornerUp) => Direction::Right,
            (Direction::Up, Tile::CornerDown) => Direction::Left,
            (Direction::Up, _) => Direction::Up,
            (Direction::Down, Tile::CornerUp) => Direction::Left,
            (Direction::Down, Tile::CornerDown) => Direction::Right,
            (Direction::Down, _) => Direction::Down,
            (Direction::Left, Tile::CornerUp) => Direction::Down,
            (Direction::Left, Tile::CornerDown) => Direction::Up,
            (Direction::Left, _) => Direction::Left,
            (Direction::Right, Tile::CornerUp) => Direction::Up,
            (Direction::Right, Tile::CornerDown) => Direction::Down,
            (Direction::Right, _) => Direction::Right,
        };
        self.direction = new_direction;
    }
}

#[derive(Debug)]
struct Simulation {
    map: Vec<Vec<Tile>>,
    carts: Vec<Cart>,
}

impl Simulation {
    fn new(map_str: &str) -> Simulation {
        let mut cells = Vec::new();
        let mut carts = Vec::new();
        let lines : Vec<&str> = map_str.lines().collect();
        for (y, line) in lines.iter().enumerate() {
            let mut row = Vec::new();
            for (x, c) in line.chars().enumerate() {
                let tile = match c {
                  '-' | '|'  => Tile::Straight,
                  '/'        => Tile::CornerUp,
                  '\\'       => Tile::CornerDown,
                  '+'        => Tile::Intersection,
                  ' '        => Tile::Empty,
                  '^' | 'v' | '<' | '>' => {
                      carts.push(Cart::new(c, (x,y)));
                      Tile::Straight
                  },
                    _ => panic!("Illegal map character: {}", c),
                };
                row.push(tile);
            }
            cells.push(row);
        }
        Simulation { map: cells, carts }
    }

    fn advance(&mut self) {
        // first sort carts by location
        self.carts.sort_by(|a,b| {
            if a.location.1 == b.location.1 {
                a.location.0.cmp(&b.location.0)
            } else {
                a.location.1.cmp(&b.location.1)
            }
        });

        // cache cart locations so we can do easier collision detection
        let mut locations = HashMap::new();
        let mut carts_to_kill = Vec::new();
        for (i, cart) in self.carts.iter().enumerate() {
            if !cart.is_dead {
                locations.insert(cart.location, i);
            }
        }

        // advance cart positions
        for (i, cart) in self.carts.iter_mut().enumerate() {
            if cart.is_dead {
                continue;
            }
            let prev_location = cart.location.clone();
            let (x,y) = cart.location;
            let tile = &self.map[y][x];
            match tile {
                Tile::Intersection => cart.turn_at_intersection(),
                Tile::CornerUp | Tile::CornerDown => cart.turn_at_corner(&tile),
                _ => (),
            }
            cart.location = match cart.direction {
                Direction::Up    => (x, y-1),
                Direction::Down  => (x, y+1),
                Direction::Left  => (x-1, y),
                Direction::Right => (x+1, y),
            };
            // check for collisions
            if let Some(cart_id) = locations.get(&cart.location) {
                println!("Collision at {:?}", cart.location);
                cart.is_dead = true;
                carts_to_kill.push(*cart_id); // need to do this outside the loop or rust has a fit
            } else {
                locations.remove(&prev_location);
                locations.insert(cart.location, i);
            }
        }

        for id in carts_to_kill {
            self.carts[id].is_dead = true;
        }
    }

    fn live_carts(&self) -> Vec<Cart> {
        // rust is ridiculous
        self.carts.iter()
            .filter(|&c| !c.is_dead)
            .cloned()
            .into_iter()
            .collect::<Vec<Cart>>()
    }
}

fn main() {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer).expect("Error reading from stdin");
    let mut sim = Simulation::new(&buffer);

//    sim.advance();
//    println!("{:#?}", sim);
    'main: loop {
        sim.advance();
        let live_carts = sim.live_carts();
//        println!("live: {}", live_carts);
        match live_carts.len() {
            0 => {
                println!("No carts left!");
                break 'main;
            },
            1 => {
                println!("Last cart at {:?}", live_carts[0].location);
                break 'main;
            },
            _ => (),
        }
    }
}
