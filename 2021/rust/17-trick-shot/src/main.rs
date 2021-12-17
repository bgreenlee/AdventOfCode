use std::ops::RangeInclusive;

fn main() {
    let target_area = (85..=145, -163..=-108);

    let mut velocities = find_all_velocities(&target_area);
    velocities.sort_by(|a, b| b.max_height.cmp(&a.max_height)); // sort by descending max height
    println!("Part 1: {} at {:?}", velocities[0].max_height, velocities[0].velocity);
    println!("Part 2: {}", velocities.len());
}

type TargetArea = (RangeInclusive<i32>, RangeInclusive<i32>);
type Velocity = (i32, i32);

struct Firing {
    velocity: Velocity,
    max_height: i32,
}

// find all velocities that hit the target
// return a list of velocities along with their max height
fn find_all_velocities(target_area: &TargetArea) -> Vec<Firing> {
    let mut velocities = Vec::new();

    for vx in 1..=*target_area.0.end() {
        for vy in *target_area.1.start()..=200 { // nothing scientific about this end range
            let velocity = (vx, vy);
            match fire(velocity, &target_area) {
                Some(max_height) => velocities.push(Firing{velocity, max_height}),
                None => {}
            }
        }
    }
    velocities
}

// fire with the given velocity
// if we hit the target area, return Some(max height), None otherwise
fn fire(velocity: Velocity, target_area: &TargetArea) -> Option<i32> {
    let (mut vx, mut vy) = velocity;
    let mut px = 0;
    let mut py = 0;
    let mut max_height = i32::MIN;

    loop {
        px += vx;
        py += vy;
        if py > max_height {
            max_height = py;
        }
        // drag
        if vx > 0 {
            vx -= 1;
        } else if vx < 0 {
            vx += 1;
        }
        vy -= 1; // gravity

        // check for target hit
        if target_area.0.contains(&px) && target_area.1.contains(&py) {
            return Some(max_height);
        }

        // check for overshooting target
        if px > *target_area.0.end() || py < *target_area.1.start() {
            return None
        }
    }
}

#[allow(unused_macros)]
macro_rules! dbg {
    ($x:expr) => {
        println!("{} = {:?}",stringify!($x),$x);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_fire() {
        let target_area = (20..=30, -10..=-5);
        assert_eq!(fire((6, 9),    &target_area), Some(45));
        assert_eq!(fire((17, -4), &target_area), None);
        assert!(fire((7, -1), &target_area).is_some());
        assert!(fire((6, 0), &target_area).is_some());
    }

    #[test]
    fn test_find_all_velocities() {
        let target_area = (20..=30, -10..=-5);
        let num_velocities = find_all_velocities(&target_area).len();
        assert_eq!(num_velocities, 112);
    }
}