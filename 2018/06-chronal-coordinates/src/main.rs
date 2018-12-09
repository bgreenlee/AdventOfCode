use std::io::{self, Read};
use std::collections::HashMap;
use std::hash::{Hash, Hasher};
use std::cmp::{Eq, PartialEq};

type Csize = i16;

#[derive(Debug,Copy)]
struct Point {
    x: Csize,
    y: Csize,
}

impl Clone for Point {
    fn clone(&self) -> Point { *self }
}

impl Hash for Point {
    fn hash<H: Hasher>(&self, state: &mut H) {
        self.x.hash(state);
        self.y.hash(state);
    }
}

impl PartialEq for Point {
    fn eq(&self, other: &Point) -> bool {
        self.x == other.x && self.y == other.y
    }
}

impl Eq for Point {}

impl Point {
    fn new(points: &str) -> Point {
        let parts : Vec<Csize> = points.split(",")
            .map(|c:&str| c.trim().parse::<Csize>().unwrap_or(0))
            .collect();

        Point {
            x: parts[0],
            y: parts[1],
        }
    }

    fn distance_to(&self, other: &Point) -> Csize {
        (self.x - other.x).abs() + (self.y - other.y).abs()
    }
}

#[derive(Debug)]
struct Map<'a> {
    waypoints: &'a Vec<Point>,
    field: HashMap<Point, Option<&'a Point>>,
    field_distances: HashMap<Point, Csize>,
    left: Csize,
    top: Csize,
    width: Csize,
    height: Csize,
}

impl<'a> Map<'a> {
    fn new(points: &'a Vec<Point>) -> Map<'a> {
        let left = points.iter().map(|p| p.x).min().unwrap();
        let right = points.iter().map(|p| p.x).max().unwrap();
        let top = points.iter().map(|p| p.y).min().unwrap();
        let bottom = points.iter().map(|p| p.y).max().unwrap();
        let width = right - left;
        let height = bottom - top;
        let field = HashMap::new();
        let field_distances = HashMap::new();
        let waypoints = points;

        Map { waypoints, field, field_distances, left, top, width, height }
    }

    fn waypoint_distances(&self, point:&'a Point) -> Vec<Csize> {
        self.waypoints.iter()
            .map(|p| p.distance_to(point))
            .collect()
    }

    fn closest_waypoint(&mut self, point:Point) -> Option<&'a Point> {
        let distances= self.waypoints.iter()
            .map(|p| (p, p.distance_to(&point)));
        let min_distance = distances.clone().map(|d| d.1).min().unwrap();
        // if more that one has the same minimum distance, return None
        match distances.clone().filter(|d| d.1 == min_distance).count() {
            1 => {
                let distance = distances.clone().find(|d| d.1 == min_distance).unwrap();
                Some(distance.0)
            },
            _ => None,
        }
    }

    fn populate(&mut self) {
        for x in self.left..=self.left+self.width {
            for y in self.top..=self.top+self.height {
                let point = Point{x,y};
                let closest = self.closest_waypoint(point);
                self.field.insert(point.clone(), closest);
            }
        }
    }

    fn populate_distances(&mut self) {
        for x in self.left..=self.left + self.width {
            for y in self.top..=self.top + self.height {
                let point = Point { x, y };
                let total_distance = self.waypoint_distances(&point).iter().sum();
                self.field_distances.insert(point.clone(), total_distance);
            }
        }
    }

    fn is_on_edge(&self, point: &'a Point) -> bool {
        point.x == self.left || point.x == self.left + self.width ||
            point.y == self.top  || point.y == self.top  + self.height
    }

    fn waypoint_size(&self, point:&'a Point) -> isize {
        // if the point is on the edge of the map, it's infinite; return -1
        if self.is_on_edge(point) {
           return -1;
        }

        let field_points= self.field.iter()
            .filter(|cell| *cell.1 == Some(point))
            .map(|cell| *cell.0);

        if field_points.clone().any(|p| self.is_on_edge(&p)) {
            return -1;
        }

        field_points.count() as isize
    }
}

fn main() {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer).expect("Error reading from stdin");
    let input : Vec<Point> = buffer.lines().map(Point::new).collect();

    let mut map = Map::new(&input);
    map.populate();

    //println!("{:#?}", map);

//    for waypoint in map.waypoints {
//        let size = map.waypoint_size(waypoint);
//        println!("{:?} => {}", waypoint, size);
//    }
    let max_size = map.waypoints.iter().map(|wp| map.waypoint_size(wp)).max().unwrap();
    println!("max size: {}", max_size);

    map.populate_distances();
    let safe_size = map.field_distances.values().filter(|v| **v < 10000).count();
    println!("safe size: {}", safe_size);
}

//#[cfg(test)]
//mod tests {
//    use super::*;
//
//    #[test]
//    fn test_overlap() {
//    }
//
//}
