use std::io::{self, Read};
use std::collections::HashMap;

type Location = (i32,i32);

#[derive(Debug)]
struct Map {
    locations: HashMap<Location,usize>,
    current_location: Location,
}

impl Map {
    fn new() -> Map {
        let mut locations = HashMap::new();
        let current_location = (0,0);
        locations.insert(current_location, 0);
        Map { locations, current_location }
    }

    fn add_step(&mut self, dir: char) {
        let next_location = match dir {
            'N' => (self.current_location.0,     self.current_location.1 - 1),
            'E' => (self.current_location.0 + 1, self.current_location.1),
            'S' => (self.current_location.0,     self.current_location.1 + 1),
            'W' => (self.current_location.0 - 1, self.current_location.1),
             _  => self.current_location,
        };
        // check to see if we've already visited the next_location
        // if so, update the distance only if we're getting there a shorter way
        let current_dist = *self.locations.get(&self.current_location).unwrap();
        if let Some(dist) = self.locations.get(&next_location) {
            if *dist > current_dist + 1 {
                self.locations.insert(next_location, current_dist + 1);
            }
        } else {
            self.locations.insert(next_location, current_dist + 1);
        }
        self.current_location = next_location;
    }

    fn from_string(input: &str) -> Map {
        let mut map = Map::new();

        let mut location_stack = Vec::new();
        location_stack.push(map.current_location);

        for c in input.chars() {
            match c {
                'N'|'E'|'S'|'W' => map.add_step(c),
                '(' => location_stack.push(map.current_location),
                '|' => map.current_location = *location_stack.last().unwrap(),
                ')' => map.current_location = location_stack.pop().unwrap(),
                _ => (),
            }
        }

        map
    }

    fn max_distance(&self) -> usize {
        *self.locations.values().max().unwrap()
    }
}

fn main() {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer).expect("Error reading from stdin");
    let map = Map::from_string(&buffer);
    println!("Max distance: {}", map.max_distance());
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_max_distance() {
        let mut test_cases = HashMap::new();
        test_cases.insert("^WNE$", 3);
        test_cases.insert("^ENWWW(NEEE|SSE(EE|N))$", 10);
        test_cases.insert("^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$", 18);
        test_cases.insert("^ESSWWN(E|NNENN(EESS(WNSE|)SSS|WWWSSSSE(SW|NNNE)))$", 23);
        test_cases.insert("^WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS))))$", 31);

        for (input, answer) in test_cases {
            let map = Map::from_string(input);
            assert_eq!(map.max_distance(), answer);
        }
    }
}
