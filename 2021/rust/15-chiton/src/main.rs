use std::io::{self, Read};
use std::collections::{BinaryHeap, HashMap};
use std::cmp::Ordering;

type Point = (usize, usize);

#[derive(Copy, Clone, Eq, PartialEq, Debug)]
struct Cell {
    location: Point,
    fscore: u32,
}

// ordering for priority queue as a min-heap
impl Ord for Cell {
    fn cmp(&self, other: &Self) -> Ordering {
        other.fscore.cmp(&self.fscore)
    }
}

impl PartialOrd for Cell {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

fn main() {
    let mut buffer = String::new();
    io::stdin()
        .read_to_string(&mut buffer)
        .expect("Error reading from stdin");
    let lines: Vec<&str> = buffer.lines().collect();

    // populate map
    let map = generate_map(&lines, 1);
    let path = a_star(&map, (0,0), (map[0].len()-1, map.len()-1)).unwrap();
    let score: u32 = path.iter().map(|(x,y)| map[*y][*x]).sum::<u32>() - map[0][0];
    println!("part 1: {}", score);

    let map = generate_map(&lines, 5);
    let path = a_star(&map, (0,0), (map[0].len()-1, map.len()-1)).unwrap();
    let score: u32 = path.iter().map(|(x,y)| map[*y][*x]).sum::<u32>() - map[0][0];
    println!("part 2: {}", score);

}

fn generate_map(lines: &Vec<&str>, multiplier: usize) -> Vec<Vec<u32>> {
    let height = lines.len();
    let width = lines[0].len();
    let mut map: Vec<Vec<u32>> = vec![vec![0; width * multiplier]; height * multiplier];
    for i in 0usize..multiplier {
        for j in 0usize..multiplier {
            for y in 0..height {
                for (x, c) in lines[y].char_indices() {
                    let mut risk = c.to_digit(10).unwrap() + i as u32 + j as u32;
                    while risk > 9 {
                        risk -= 9;
                    }
                    map[height * i + y][width * j + x] = risk;
                }
            }
        }
    }
    map
}

fn reconstruct_path(came_from: &HashMap<Point, Point>, point: Point) -> Vec<Point> {
    let mut total_path = vec![point];
    let mut current = point;
    while came_from.get(&current).is_some() {
        current = *came_from.get(&current).unwrap();
        total_path.push(current);
    }
    total_path.reverse();
    total_path
}

fn heuristic(start: Point, goal: Point) -> u32 {
    // use Manhattan distance as our estimate
    goal.0 as u32 - start.0 as u32 +
    goal.1 as u32 - start.1 as u32
}

fn neighbors(map: &Vec<Vec<u32>>, point: Point) -> Vec<Point> {
    let mut neighbors: Vec<Point> = Vec::new();
    let height = map.len();
    let width = map[0].len();
    let (x, y) = point;
    if y > 0 {
        neighbors.push((x, y-1));
    }
    if x < width - 1 {
        neighbors.push((x+1, y));
    }
    if y < height - 1 {
        neighbors.push((x, y+1));
    }
    if x > 0 {
        neighbors.push((x-1, y));
    }
    neighbors
}

// from https://en.wikipedia.org/wiki/A*_search_algorithm
fn a_star(map: &Vec<Vec<u32>>, start: Point, goal: Point) -> Option<Vec<Point>> {
    let max_val = u32::MAX - 9; // our "Infinity"; 9 is the highest risk value

    // The set of discovered nodes that may need to be (re-)expanded.
    // Initially, only the start node is known.
    let mut open_set: BinaryHeap<Cell> = BinaryHeap::new();
    open_set.push(Cell{location: start, fscore: map[0][0]});

    // For node n, came_from[n] is the node immediately preceding it on the cheapest path from start
    // to n currently known.
    let mut came_from: HashMap<Point, Point> = HashMap::new();

    // For node n, gscore[n] is the cost of the cheapest path from start to n currently known.
    let mut gscore: HashMap<Point, u32> = HashMap::new();
    gscore.insert(start, 0);

    // For node n, fscore[n] := gscore[n] + heuristic(n, goal). fscore[n] represents our current best guess as to
    // how short a path from start to finish can be if it goes through n.
    let mut fscore: HashMap<Point, u32> = HashMap::new();
    fscore.insert(start, heuristic(start, goal));

    while let Some(current) = open_set.pop() {
        // println!("current: {:?}", current);
        if current.location == goal {
            return Some(reconstruct_path(&came_from, current.location));
        }
        
        for neighbor in neighbors(map, current.location) {
            let neighbor_risk = map[neighbor.1][neighbor.0];
            // println!("neighbor: {:?} ({})", neighbor, neighbor_risk);
            let tentative_gscore = *gscore.get(&current.location).unwrap_or(&max_val) + neighbor_risk;
            if tentative_gscore < *gscore.get(&neighbor).unwrap_or(&max_val) {
                came_from.insert(neighbor, current.location);
                // println!("came from: {:?}", came_from);
                gscore.insert(neighbor, tentative_gscore);
                fscore.insert(neighbor, tentative_gscore + heuristic(neighbor, goal));
                
                let open_set_points: Vec<_> = open_set.clone()
                    .into_vec()
                    .iter()
                    .map(|cell| cell.location)
                    .collect();
                
                if !open_set_points.contains(&neighbor) {
                    open_set.push(Cell{location: neighbor, fscore: *fscore.get(&neighbor).unwrap_or(&max_val)});
                }
            }
        }
    }

    return None
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn min_heap() {
        let mut heap: BinaryHeap<Cell> = BinaryHeap::new();
        heap.push(Cell{location: (0,0), fscore: 3});
        heap.push(Cell{location: (1,0), fscore: 2});
        heap.push(Cell{location: (0,1), fscore: 7});

        assert_eq!(heap.pop().unwrap(), Cell{location: (1,0), fscore: 2});
    }
}