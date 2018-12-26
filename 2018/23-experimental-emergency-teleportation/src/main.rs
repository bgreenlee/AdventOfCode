#[macro_use] extern crate lazy_static;
use std::io::{self, Read};
use std::cmp::Ordering;
use regex::Regex;
use std::collections::BinaryHeap;

#[derive(Debug,Copy,Clone,Eq,PartialEq,Hash)]
struct Point {
    x: i128,
    y: i128,
    z: i128,
}

impl Point {
    fn origin() -> Point {
        Point { x: 0, y: 0, z: 0 }
    }

    fn scalar(&self) -> i128 {
        self.x * self.y * self.z
    }

    fn distance_to(&self, other: &Point) -> i128 {
        (self.x - other.x).abs() + (self.y - other.y).abs() + (self.z - other.z).abs()
    }

    fn distance_to_origin(&self) -> i128 {
        self.distance_to(&Point::origin())
    }

}

impl Ord for Point {
    fn cmp(&self, other: &Point) -> Ordering {
        //self.distance_to_origin().cmp(&other.distance_to_origin())
        self.scalar().partial_cmp(&other.scalar()).unwrap_or(Ordering::Equal)
    }
}

impl PartialOrd for Point {
    fn partial_cmp(&self, other: &Point) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

#[derive(Debug,Eq,PartialEq,Hash)]
struct Bot {
    point: Point,
    r: i128,
}

impl Bot {
    fn from_string(input: &str) -> Bot {
        lazy_static! {
            // pos=<0,0,0>, r=4
            static ref RE: Regex = Regex::new(r"pos=<(-?\d+),(-?\d+),(-?\d+)>, r=(\d+)").unwrap();
        }
        let caps = RE.captures(input).unwrap().iter()
            .skip(1)
            .map(|c| c.unwrap().as_str().parse::<i128>().unwrap())
            .collect::<Vec<_>>();
        Bot { point: Point { x: caps[0], y: caps[1], z: caps[2] }, r: caps[3]}
    }

    fn min_point(&self) -> Point {
        Point { x: self.point.x - self.r, y: self.point.y - self.r, z: self.point.z - self.r }
    }

    fn max_point(&self) -> Point {
        Point { x: self.point.x + self.r, y: self.point.y + self.r, z: self.point.z + self.r }
    }

    fn bounding_box(&self) -> Box {
        Box { min: self.min_point(), max: self.max_point() }
    }

    fn distance(&self, other: &Bot) -> i128 {
        ((self.point.x - other.point.x).abs() +
            (self.point.y - other.point.y).abs() +
            (self.point.z - other.point.z).abs())
    }

    fn in_range(&self, other: &Bot) -> bool {
        self.distance(other) <= self.r
    }

    // return true if this bot's range overlaps the given box
    fn overlaps(&self, bx: &Box) -> bool {
        let mut d = 0;
        let (x,y,z) = (self.point.x, self.point.y, self.point.z);
        if x > bx.max.x {
            d += x - bx.max.x;
        } else if x < bx.min.x {
            d += bx.min.x - x;
        }
        if y > bx.max.y {
            d += y - bx.max.y;
        } else if y < bx.min.y {
            d += bx.min.y - y;
        }
        if z > bx.max.z {
            d += z - bx.max.z;
        } else if z < bx.min.z {
            d += bx.min.z - z;
        }
        d <= self.r
    }
}

#[derive(Debug,Copy,Clone,Eq,PartialEq,Hash)]
struct Box {
    min: Point,
    max: Point,
}

impl Box {
    fn volume(&self) -> i128 {
        (self.max.x - self.min.x + 1) * (self.max.y - self.min.y + 1) * (self.max.z - self.min.z + 1)
    }

    fn midpoint(&self) -> Point {
        Point { x: self.min.x + (self.max.x - self.min.x) / 2,
            y: self.min.y + (self.max.y - self.min.y) / 2,
            z: self.min.z + (self.max.z - self.min.z) / 2 }
    }

    // split this box into eight if we can
    fn split(&self) -> Vec<Box> {
        let min = self.min;
        let max = self.max;
        let mid = self.midpoint();
        println!("mid: {:?}", mid);
        let mut splits = vec![
            // top NW
            Box { min, max: mid }
        ];

        if mid.x < max.x {
            // top NE
            splits.push(Box { min: Point { x: mid.x + 1, y: min.y, z: min.z }, max: Point { x: max.x, y: mid.y, z: mid.z } });
        }

        if mid.x < max.x && mid.z < max.z {
            // top SE
            splits.push(Box { min: Point { x: mid.x + 1, y: min.y, z: mid.z + 1 }, max: Point { x: max.x, y: mid.y, z: max.z } });
        }

        if mid.z < max.z {
            // top SW
            splits.push(Box { min: Point { x: min.x, y: min.y, z: mid.z + 1 }, max: Point { x: mid.x, y: mid.y, z: max.z } });
        }

        if mid.y < max.y {
            // bottom NW
            splits.push(Box { min: Point { x: min.x, y: mid.y + 1, z: min.z }, max: Point { x: mid.x, y: max.y, z: mid.z } });
        }

        if mid.x < max.x && mid.y < max.y {
            // bottom NE
            splits.push(Box { min: Point { x: mid.x + 1, y: mid.y + 1, z: min.z }, max: Point { x: max.x, y: max.y, z: mid.z } });
        }

        if mid.x < max.x && mid.y < max.y && mid.z < max.z {
            // bottom SE
            splits.push(Box { min: Point { x: mid.x + 1, y: mid.y + 1, z: mid.z + 1}, max });
        }

        if mid.y < max.y && mid.z < max.z {
            // bottom SW
            splits.push(Box { min: Point { x: min.x, y: mid.y + 1, z: mid.z + 1 }, max: Point { x: mid.x, y: max.y, z: max.z } });
        }

        splits

    }
}

fn generate_bounding_box(boxes: &Vec<Box>) -> Box {
    // generate bounding box around all boxes
    let mut min = Point { x: i128::max_value(), y: i128::max_value(), z: i128::max_value() };
    let mut max = Point { x: i128::min_value(), y: i128::min_value(), z: i128::min_value() };
    for bx in boxes {
        min.x = bx.min.x.min(min.x);
        min.y = bx.min.y.min(min.y);
        min.z = bx.min.z.min(min.z);
        max.x = bx.max.x.max(max.x);
        max.y = bx.max.y.max(max.y);
        max.z = bx.max.z.max(max.z);
    }
    Box { min, max }
}

#[derive(Debug,Eq,PartialEq)]
struct SearchArea {
    area: Box,
    num_bots: usize,
}

impl Ord for SearchArea {
    // order by num_bots, then distance to origin, then volume
    fn cmp(&self, other: &SearchArea) -> Ordering {
        if self.num_bots == other.num_bots {
            if self.area.midpoint().distance_to_origin() == other.area.midpoint().distance_to_origin() {
                self.area.volume().cmp(&other.area.volume())
            } else {
                self.area.midpoint().distance_to_origin().cmp(&other.area.midpoint().distance_to_origin())
            }
        } else {
            self.num_bots.cmp(&other.num_bots)
        }
    }
}

impl PartialOrd for SearchArea {
    fn partial_cmp(&self, other: &SearchArea) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

fn main() {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer).expect("Error reading from stdin");

    let mut bots = buffer.lines().map(|l| Bot::from_string(l)).collect::<Vec<_>>();
    bots.sort_by(|a,b| a.r.cmp(&b.r));
    let strongest_bot = bots.last().unwrap();
    println!("Strongest: {:?}", strongest_bot);
    let in_range = bots.iter()
        .filter(|b| strongest_bot.in_range(b))
        .count();
    println!("In range: {}", in_range);


    // Part 2
    // find bounding box with most overlaps
    // divide that box into eight
    // repeat until box volume == 1

    // start with a bounding box around all bots
    let mut search_queue = BinaryHeap::new();
    let bounding_box = generate_bounding_box(&bots.iter().map(Bot::bounding_box).collect::<Vec<_>>());
    let num_bots = bots.iter().filter(|b| b.overlaps(&bounding_box)).count();
    search_queue.push(SearchArea { area: bounding_box, num_bots });
    while let Some(search_area) = search_queue.pop() {
        println!("search area: {:?} (volume: {})", search_area, search_area.area.volume());
        if search_area.area.volume() == 1 {
            // we got our answer!
            println!("distance: {}", search_area.area.min.distance_to_origin());
            break;
        }
        for split in &search_area.area.split() {
            let num_bots = bots.iter().filter(|b| b.overlaps(split)).count();
            println!("split: {:?}, bots: {}", split, num_bots);
            search_queue.push( SearchArea { area: *split, num_bots });
        }
    }
}
