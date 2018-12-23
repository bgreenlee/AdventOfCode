use std::env;
use std::collections::HashMap;

//enum Region {
//    Rocky = 0,
//    Wet = 1,
//    Narrow = 2,
//}

struct Map {
    depth: usize,
    target: (usize,usize),
    gi_cache: HashMap<(usize, usize),usize>,
}

impl Map{
    fn new(depth: usize, target: (usize,usize)) -> Map {
        Map { depth, target, gi_cache: HashMap::new() }
    }

    fn geologic_index(&mut self, location: (usize,usize)) -> usize {
        if let Some(index) = self.gi_cache.get(&location) {
            return *index;
        }
        if location == (0,0) || location == self.target {
            return 0;
        }
        if location.1 == 0 {
            return location.0 * 16807;
        }
        if location.0 == 0 {
            return location.1 * 48271;
        }
        let index = self.erosion_level((location.0 - 1, location.1)) * self.erosion_level((location.0, location.1 - 1));
        self.gi_cache.insert(location, index);
        index
    }

    fn erosion_level(&mut self, location: (usize,usize)) -> usize {
        (self.geologic_index(location) + self.depth) % 20183
    }

    fn risk_level(&mut self, location: (usize,usize)) -> usize {
        self.erosion_level(location) % 3
    }
}


fn main() {
    let depth = env::args().nth(1).unwrap().parse::<usize>().unwrap();
    let target_parts = env::args().nth(2).unwrap()
        .split(",")
        .map(|s| s.parse::<usize>().unwrap()).collect::<Vec<_>>();
    let target = (target_parts[0], target_parts[1]);

    let mut map = Map::new(depth, target);

    let mut total: usize = 0;
    for x in 0..=target.0 {
        for y in 0..=target.1 {
            total += map.risk_level((x,y));
        }
    }
    println!("Total risk: {}", total);
}
