use std::io::{self, Read};
use std::collections::{HashMap, HashSet};
use std::cmp::{Eq, PartialEq};
use std::hash::{Hash, Hasher};
use std::fmt;
use std::ops::{Add, Sub, Neg};

// cribbed from https://github.com/prscoelho/aoc2021/blob/main/a19.rs

fn main() {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer)
        .expect("Error reading from stdin");

    let beacons = parse_beacons(&buffer);
    let (all_beacons, scanner_locations) = normalize_beacons(beacons);
    println!("Part 1: {}", all_beacons.len());
    println!("Part 2: {}", max_distance(scanner_locations));
}

type Distances = HashMap<Point, HashSet<u32>>;

// Parse our input text into beacons
fn parse_beacons(input: &str) -> Vec<HashSet<Point>> {
    let mut beacons = Vec::new();
    for scanner_text in input.split("\n\n") {
        let mut current_set = HashSet::new();
        for line in scanner_text.split("\n").skip(1) {
            current_set.insert(Point::new_from_str(line));
        }
        beacons.push(current_set);
    }
    beacons
}

// Normalize all beacons to the origin (scanner 0)
// Return the set of normalized beacons and list of scanner locations
fn normalize_beacons(mut beacons: Vec<HashSet<Point>>) -> (HashSet<Point>, Vec<Point>) {
    let mut scanner_locations = vec![Point::new(0, 0, 0)];
    let mut origin_beacons = beacons.remove(0);

    let mut beacon_distances = beacons.iter().map(distances).collect::<Vec<_>>();

    while !beacons.is_empty() {
        let origin_distances = distances(&origin_beacons);
        let (origin_center, other_center, scanner_idx) = find_center_pair(origin_distances, &beacon_distances).unwrap();
        let (translated_center, translated_points) = match_orientation(
            &origin_beacons,
            &beacons[scanner_idx],
            origin_center,
            other_center,
        )
        .unwrap();

        origin_beacons.extend(translated_points);
        scanner_locations.push(translated_center);

        beacon_distances.remove(scanner_idx);
        beacons.remove(scanner_idx);        
    }

    (origin_beacons, scanner_locations)
}

// Return a mapping of each point to the set of manhattan distances to all other points
fn distances(beacons: &HashSet<Point>) -> Distances {
    let mut result = Distances::with_capacity(beacons.len());
    for from_beacon in beacons {
        let mut dists = HashSet::new();
        for to_beacon in beacons {
            if from_beacon == to_beacon {
                continue;
            }
            dists.insert(from_beacon.distance(to_beacon));
        }
        result.insert(*from_beacon, dists);
    }
    result
}

// Given two sets of point -> distance mappings, find two points that have 12 or more
// overlapping distances. This indicates that they are most likely the same point in
// different coordinate systems.
// Return the two points along with the index of the matched set in beacon_distances.
fn find_center_pair(origin_distances: Distances, beacon_distances: &Vec<Distances>) -> Option<(Point, Point, usize)> {
    for (origin_center, origin_dists) in origin_distances {
        for (idx, scanner) in beacon_distances.iter().enumerate() {
            for (other_center, other_dists) in scanner {
                // if we have at least 12 overlapping distances to other points, these are most
                // likely the same point in different coordinate systems
                if origin_dists.intersection(other_dists).count() >= 12 {
                    return Some((origin_center, *other_center, idx));
                }
            }
        }
    }
    None
}

// find an orientation that allows us to map other_beacons to origin_beacons
// return the location of the other scanner and the translated other points
fn match_orientation(
    origin_beacons: &HashSet<Point>, other_beacons: &HashSet<Point>,
    origin_center: Point, other_center: Point,
) -> Option<(Point, HashSet<Point>)> {
    for direction in [Direction::Pos, Direction::Neg] {
        for axis in [Axis::X, Axis::Y, Axis::Z] {
            for rotation in [0, 90, 180, 270] {
                let translated_center = other_center.translate(direction, axis, rotation);
                let center_diff = translated_center - origin_center;
                let translated_set: HashSet<Point> = other_beacons
                    .iter()
                    .map(|p| p.translate(direction, axis, rotation) - center_diff)
                    .collect();
                if origin_beacons.intersection(&translated_set).count() >= 12 {
                    return Some((-center_diff, translated_set));
                }
            }
        }
    }

    None
}

// find the maximum distance between any two scanners
fn max_distance(scanner_locations: Vec<Point>) -> u32 {
    let mut distances = Vec::new();
    for a in scanner_locations.iter() {
        for b in scanner_locations.iter() {
            if a != b {
                distances.push(a.distance(b));
            }
        }
    }
    distances.into_iter().max().unwrap()
}

#[derive(Clone,Copy)]
struct Point {
    x: i32,
    y: i32,
    z: i32,
}

impl Point {
    fn new_from_str(line: &str) -> Point {
        let parts: Vec<&str> = line.split(",").collect();
        if parts.len() != 3 {
            panic!("Invalid point: {}", line);
        }
        Point {
            x: parts[0].parse().unwrap(),
            y: parts[1].parse().unwrap(),
            z: parts[2].parse().unwrap(),
        }
    }

    fn new(x: i32, y: i32, z: i32) -> Point {
        Point { x, y, z }
    }

    // manhattan distance between points
    fn distance(&self, other: &Point) -> u32 {
        ((other.x - self.x).abs() +
        (other.y - self.y).abs() +
        (other.z - self.z).abs()) as u32
    }

    fn translate(&self, direction: Direction, axis: Axis, rotation: u32) -> Point {
        let (x, y, z) = (self.x, self.y, self.z);
        // sigh
        match (direction, axis, rotation) {
            (Direction::Pos, Axis::X,   0) => Point::new( x,  y,  z),
            (Direction::Pos, Axis::X,  90) => Point::new( x,  z, -y),
            (Direction::Pos, Axis::X, 180) => Point::new( x, -y, -z),
            (Direction::Pos, Axis::X, 270) => Point::new( x, -z,  y),

            (Direction::Neg, Axis::X,   0) => Point::new(-x,  y, -z),
            (Direction::Neg, Axis::X,  90) => Point::new(-x,  z,  y),
            (Direction::Neg, Axis::X, 180) => Point::new(-x, -y,  z),
            (Direction::Neg, Axis::X, 270) => Point::new(-x, -z, -y),

            (Direction::Pos, Axis::Y,   0) => Point::new(-z,  x, -y),
            (Direction::Pos, Axis::Y,  90) => Point::new( y,  x, -z),
            (Direction::Pos, Axis::Y, 180) => Point::new( z,  x,  y),
            (Direction::Pos, Axis::Y, 270) => Point::new(-y,  x,  z),

            (Direction::Neg, Axis::Y,   0) => Point::new(-z, -x,  y),
            (Direction::Neg, Axis::Y,  90) => Point::new( y, -x,  z),
            (Direction::Neg, Axis::Y, 180) => Point::new( z, -x, -y),
            (Direction::Neg, Axis::Y, 270) => Point::new(-y, -x, -z),

            (Direction::Pos, Axis::Z,   0) => Point::new(-z,  y,  x),
            (Direction::Pos, Axis::Z,  90) => Point::new( y,  z,  x),
            (Direction::Pos, Axis::Z, 180) => Point::new( z, -y,  x),
            (Direction::Pos, Axis::Z, 270) => Point::new(-y, -z,  x),

            (Direction::Neg, Axis::Z,   0) => Point::new( z,  y, -x),
            (Direction::Neg, Axis::Z,  90) => Point::new(-y,  z, -x),
            (Direction::Neg, Axis::Z, 180) => Point::new(-z, -y, -x),
            (Direction::Neg, Axis::Z, 270) => Point::new( y, -z, -x),

            _ => panic!(),
        }
    }
}

impl Sub for Point {
    type Output = Self;

    fn sub(self, other: Self) -> Self::Output {
        Self {
            x: self.x - other.x,
            y: self.y - other.y,
            z: self.z - other.z,
        }
    }
}

impl Add for Point {
    type Output = Self;

    fn add(self, other: Self) -> Self::Output {
        Self {
            x: self.x + other.x,
            y: self.y + other.y,
            z: self.z + other.z,
        }
    }
}

impl Neg for Point {
    type Output = Self;

    fn neg(self) -> Self::Output {
        Self {
            x: -self.x,
            y: -self.y,
            z: -self.z,
        }
    }
}

impl fmt::Display for Point {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "({}, {}, {})", self.x, self.y, self.z)
    }
}

impl fmt::Debug for Point {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "({}, {}, {})", self.x, self.y, self.z)
    }
}

impl PartialEq for Point {
    fn eq(&self, other: &Point) -> bool {
        self.x == other.x &&
        self.y == other.y &&
        self.z == other.z
    }
}

impl Eq for Point {}

impl Hash for Point {
    fn hash<H: Hasher>(&self, state: &mut H) {
        self.x.hash(state);
        self.y.hash(state);
        self.z.hash(state);
    }
}

#[derive(Clone,Copy,Debug)]
enum Direction {
    Pos,
    Neg,
}
impl fmt::Display for Direction {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{:?}", self)
    }
}
impl Neg for Direction {
    type Output = Self;

    fn neg(self) -> Self::Output {
        match self {
            Direction::Pos => Direction::Neg,
            Direction::Neg => Direction::Pos,
        }
    }
}

#[derive(Clone,Copy,Debug)]
enum Axis { X, Y, Z }

impl fmt::Display for Axis {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{:?}", self)
    }
}

#[allow(unused_macros)]
macro_rules! dbg {
    ($x:expr) => {
        println!("{} = {:?}",stringify!($x),$x);
    }
}