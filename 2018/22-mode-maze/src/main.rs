use std::env;
use std::collections::{BinaryHeap, HashMap};
use std::cmp::Ordering;
use std::usize;

#[derive(Debug,Eq,PartialEq,Hash,Clone,Copy)]
enum Tool {
    Climbing = 0,
    Torch = 1,
    Neither = 2,
}

#[derive(Debug,Eq,PartialEq,Hash,Clone,Copy)]
enum RegionType {
    Rocky = 0,
    Wet = 1,
    Narrow = 2,
    Unknown = 3,
}

impl RegionType {
    // this is dumb, but Rust has no native way to go from int -> enum, so we repeat ourselves
    // there is a "num" crate that can help us out, but seems silly to include that to avoid a
    // few extra lines
    fn from_usize(value: usize) -> RegionType {
        match value {
            0 => RegionType::Rocky,
            1 => RegionType::Wet,
            2 => RegionType::Narrow,
            _ => RegionType::Unknown,
        }
    }

    fn allowed_tools(self) -> Vec<Tool> {
        match self {
            RegionType::Rocky  => vec![Tool::Climbing, Tool::Torch],
            RegionType::Wet    => vec![Tool::Climbing, Tool::Neither],
            RegionType::Narrow => vec![Tool::Torch, Tool::Neither],
            _ => vec![],
        }
    }
}

type Location = (usize, usize);

#[derive(Debug,Eq,PartialEq,Hash,Clone,Copy)]
struct Region {
    location: Location,
    geologic_index: usize,
    erosion_level: usize,
    risk_level: usize,
    region_type: RegionType,
}

impl Region {
    fn new(location: Location) -> Region {
        Region { location, geologic_index: 0, erosion_level: 0, risk_level: 0, region_type: RegionType::Unknown }
    }
}

struct Map {
    depth: usize,
    target: Location,
    gi_cache: HashMap<Location, usize>,
    regions: HashMap<Location, Region>,
    width: usize,
    height: usize,
}

impl Map {
    fn new(depth: usize, target: Location) -> Map {
        let mut map = Map { depth, target, gi_cache: HashMap::new(), regions: HashMap::new(),
            width: target.0 + 40, height: target.1 + 40};
        map.populate();
        map
    }

    // populate the map, calculating data for all regions (up to 2x target location)
    fn populate(&mut self) {
        for x in 0..self.width {
            for y in 0..self.height {
                let location = (x,y);
                let mut region = Region::new(location);
                region.geologic_index = self.geologic_index(location);
                region.erosion_level = self.erosion_level(location);
                region.risk_level = region.erosion_level % 3;
                region.region_type = RegionType::from_usize(region.erosion_level % 3);
                self.regions.insert(location, region);
            }
        }
    }

    fn geologic_index(&mut self, location: Location) -> usize {
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

        let index= self.erosion_level((location.0 - 1, location.1)) *
            self.erosion_level((location.0, location.1 - 1));
        self.gi_cache.insert(location, index);
        index
    }

    fn erosion_level(&mut self, location: Location) -> usize {
        (self.geologic_index(location) + self.depth) % 20183
    }

//    fn risk_level(&mut self, location: Location) -> usize {
//        self.erosion_level(location) % 3
//    }

    // convenience method to return the allowed tools for this location
    fn allowed_tools(&self, location: Location) -> Vec<Tool> {
        let region_type = self.regions.get(&location).unwrap().region_type.clone();
        region_type.allowed_tools()
    }

    // return list of "adjacent" nodes, along with their cost, where a node is a (location, tool)
    // you can think of switching tools as traveling to the same node, with a higher cost
    fn adjacent(&self, loc_tool: &(Location, Tool)) -> Vec<(Location, Tool, usize)> {
        let (location, tool) = loc_tool;
        let mut adjacent_locs = vec![*location];
        if location.1 > 0 {
            adjacent_locs.push((location.0, location.1 - 1));
        }
        if location.0 < self.width - 1 {
            adjacent_locs.push((location.0 + 1, location.1));
        }
        if location.1 < self.height - 1 {
            adjacent_locs.push((location.0, location.1 + 1));
        }
        if location.0 > 0 {
            adjacent_locs.push((location.0 - 1, location.1));
        }
        let mut adjacent_nodes = Vec::new();

        let current_loc_allowed_tools = self.allowed_tools(*location);
        for adjacent_loc in adjacent_locs {
            for allowed_tool in self.allowed_tools(adjacent_loc) {
                let mut cost = 0;
                if adjacent_loc != *location {
                    cost += 1;
                }
                if allowed_tool != *tool {
                    // if the next location requires a tool change, and that tool isn't allowed
                    // in our current location, we have to skip it
                    if !current_loc_allowed_tools.contains(&allowed_tool) {
                        continue;
                    }
                    cost += 7;
                }
                adjacent_nodes.push((adjacent_loc, allowed_tool, cost));
            }
        }

        adjacent_nodes
    }

    fn find_path(&self) -> (Vec<(Location,Tool)>, usize) {
        // for Dijkstra
        #[derive(Clone, Eq, PartialEq)]
        struct CostState {
            loc_tool: (Location, Tool),
            cost: usize,
        }

        // Define ordering for a min-heap (lowest distance will come out first)
        impl Ord for CostState {
            fn cmp(&self, other: &CostState) -> Ordering {
                other.cost.cmp(&self.cost)
            }
        }

        impl PartialOrd for CostState {
            fn partial_cmp(&self, other: &CostState) -> Option<Ordering> {
                Some(self.cmp(other))
            }
        }

        // dist[(location,tool)] = (current shortest cost from `start` to `location` using the given tool, prev node)
        let mut dist : HashMap<(Location, Tool), (usize, Option<(Location, Tool)>)> = self.regions.iter()
            .map(|(loc,region)| {
                region.region_type.allowed_tools().iter()
                    .map(|t| ((*loc, *t), (usize::MAX, None)))
                    .collect::<Vec<_>>()
            })
            .flatten()
            .collect::<HashMap<_, _>>();

        let mut heap = BinaryHeap::new();
        let mut path = Vec::new();

        let start: (Location, Tool) = ((0,0), Tool::Torch);
        let goal: (Location, Tool) = (self.target, Tool::Torch);
        dist.insert(start, (0, None));
        heap.push(CostState { loc_tool: start, cost: 0});

        // Examine the frontier with lower-cost nodes first (min-heap)
        while let Some(CostState { loc_tool, cost }) = heap.pop() {
            let (location, _tool) = &loc_tool;
            if *location == goal.0 {
                let mut current_cost = &dist[&goal];
                let total_cost = current_cost.0;
                path.push(goal);
                while let Some(prev) = &current_cost.1 {
                    path.push(*prev);
                    current_cost = &dist[&prev];
                }
                path.reverse();
                return (path, total_cost);
            }

            if cost > dist[&loc_tool].0 {
                continue;
            }

            // for each node we can reach, see if we can find a way with a lower cost going
            // through this node
            for (next_location, next_tool, next_cost) in self.adjacent(&loc_tool) {
                let next = CostState { loc_tool: (next_location, next_tool), cost: cost + next_cost };
                if next.cost < dist[&next.loc_tool].0 {
                    // found a better way
                    dist.insert(next.loc_tool, (next.cost, Some(loc_tool)));
                    heap.push(next);
                }
            }
        }

        (path, 0)
    }
}


fn main() {
    let depth = env::args().nth(1).unwrap().parse::<usize>().unwrap();
    let target_parts = env::args().nth(2).unwrap()
        .split(",")
        .map(|s| s.parse::<usize>().unwrap()).collect::<Vec<_>>();
    let target = (target_parts[0], target_parts[1]);

    let map = Map::new(depth, target);

    let mut total: usize = 0;
    for x in 0..=target.0 {
        for y in 0..=target.1 {
            total += map.regions.get(&(x,y)).unwrap().risk_level;
        }
    }

    println!("Total risk: {}", total);

    let (path, cost) = map.find_path();
    let max_x = path.iter().map(|(loc, _)| loc.0).max().unwrap();
    let max_y = path.iter().map(|(loc, _)| loc.1).max().unwrap();
    println!("{:?}", path);
    println!("max: ({},{})", max_x, max_y);
    println!("Cost: {}", cost);
}
