use std::io::{self, Read};
use std::collections::{HashMap, HashSet};
use std::cmp::{Eq, PartialEq};
use std::hash::{Hash, Hasher};
use std::fmt;
use std::ops::{Add, Sub, Neg};
use petgraph::graph::{NodeIndex, UnGraph};
use petgraph::algo::astar;

fn main() {
    let mut buffer = String::new();
    io::stdin()
        .read_to_string(&mut buffer)
        .expect("Error reading from stdin");
    let lines: Vec<&str> = buffer.lines().collect();

    let mut scanner_points: Vec<Vec<Point>> = Vec::new();
    let mut current_list: Vec<Point> = Vec::new();

    for line in lines {
        if line.starts_with("---") {
            continue;
        }
        if line.len() == 0 {
            scanner_points.push(current_list);
            current_list = Vec::new();
            continue;
        }
        current_list.push(Point::new_from_str(line));
    }
    scanner_points.push(current_list);

    // for each point, generate a set of distances to all other points
    // points from different scanners that have a lot of overlap will likely be the same points
    let mut scanner_point_distances: Vec<HashMap<Point, HashSet<u32>>> = Vec::new();
    for points in scanner_points.iter() {
        let mut point_distances: HashMap<Point, HashSet<u32>> = HashMap::new();
        for i in 0..points.len() {
            let mut distance_set: HashSet<u32> = HashSet::new();
            for j in 0..points.len() {
                if i == j {
                    continue;
                }
                distance_set.insert(points[i].distance(&points[j]));
            }
            point_distances.insert(points[i], distance_set);
        }
        scanner_point_distances.push(point_distances);
    }

    // mapping of transformation from a to b
    let mut mappings: HashMap<(usize, usize), Transform> = HashMap::new();
    let mut edges: Vec<(NodeIndex, NodeIndex)> = Vec::new();
    for a in 0..scanner_point_distances.len()-1 {
        for b in a+1..scanner_point_distances.len() {
            let map_a = &scanner_point_distances[a];
            let map_b = &scanner_point_distances[b];
            let mut point_pairs: Vec<(Point, Point)> = Vec::new();
            for (point_a, set_a) in map_a {
                for (point_b, set_b) in map_b {
                    let intersection_count = set_a.intersection(&set_b).count();
                    if intersection_count > 6 {
                        point_pairs.push((*point_a, *point_b)); // these points map to each other somehow
                    }
                }
            }
            if point_pairs.len() == 12 {
                // these two scanners overlap
                // figure out how their points translate
                // For each translation we attempt, generate a set of diffs of point_b - point_a.
                // When the set has only one element, we've found our translation.
                for direction in [Direction::Pos, Direction::Neg] {
                    for axis in [Axis::X, Axis::Y, Axis::Z] {
                        for rotation in [0, 90, 180, 270] {
                            let mut diffset: HashSet<Point> = HashSet::new();
                            for (point_a, point_b) in &point_pairs {
                                let trans_point_b = point_b.translate(direction, axis, rotation);
                                diffset.insert(trans_point_b - *point_a);
                            }
                            if diffset.len() == 1 { // we have our mapping
                                let diff = diffset.into_iter().next().unwrap();
                                mappings.insert((b,a), Transform { diff, direction, axis, rotation, is_rev: false });
                                mappings.insert((a,b), Transform { diff, direction, axis, rotation, is_rev: true });
                                edges.push((NodeIndex::new(a), NodeIndex::new(b)));
                            }
                        }
                    }
                }
            }
        }
    }

    // finally, generate our set of all beacons, starting with beacons from scanner 0
    let mut beacons: HashSet<Point> = HashSet::from_iter(scanner_points[0].iter().cloned());

    // create an undirected graph between scanners so we can find the path from each scanner to scanner 0
    // with this path, we can generate a list of transforms to get from scanner n to scanner 0
    let graph = UnGraph::<usize, ()>::from_edges(edges.iter());

    for i in 1..scanner_points.len() {
        let (_, path) = astar(&graph, (i as u32).into(), |end| end == 0.into(), |_| 1, |_| 0).unwrap();
        dbg!(&path);
        let mut transforms: Vec<Transform> = Vec::new();
        for p in 0..path.len()-1 {
            let map = (path[p].index(), path[p+1].index());
            transforms.push(*mappings.get(&map).unwrap());
        }
        dbg!(&transforms);
        for point in scanner_points[i].iter() {
            beacons.insert(point.transform(&transforms));
        }
    }

    let mut beacon_list: Vec<_> = beacons.into_iter().collect();
    beacon_list.sort_by(|a,b| if a.x == b.x { a.y.cmp(&b.y) } else { a.x.cmp(&b.x) });
    // dbg!(&beacon_list);
    println!("Part 1: {}", beacon_list.len());
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

    fn transform(&self, transforms: &Vec<Transform>) -> Point {
        let mut point = *self;
        for transform in transforms {
            if transform.is_rev {
                point = (point + transform.diff).translate(transform.direction, transform.axis, transform.rotation);
            } else {
                point = point.translate(transform.direction, transform.axis, transform.rotation) - transform.diff;
            }
        }
        point
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
enum Axis {
    X,
    Y,
    Z,
}
impl fmt::Display for Axis {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{:?}", self)
    }
}

#[derive(Clone,Copy)]
struct Transform {
    diff: Point,
    direction: Direction,
    axis: Axis,
    rotation: u32,
    is_rev: bool,
}

impl fmt::Debug for Transform {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{}, {}, {}, {}", self.diff, self.direction, self.axis, self.rotation)
    }
}

#[allow(unused_macros)]
macro_rules! dbg {
    ($x:expr) => {
        println!("{} = {:?}",stringify!($x),$x);
    }
}