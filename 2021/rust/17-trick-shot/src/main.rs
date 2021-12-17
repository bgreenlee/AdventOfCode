use std::ops::RangeInclusive;

fn main() {
    let target_area = (85..=145, -163..=-108);

    let (best_velocity, max_height) = find_max_height(&target_area);
    println!("Part 1: {} at {:?}", max_height, best_velocity);

    let velocities = find_all_velocities(&target_area);
    println!("Part 2: {}", velocities.len());
}

type TargetArea = (RangeInclusive<i32>, RangeInclusive<i32>);
type Velocity = (i32, i32);

fn find_max_height(target_area: &TargetArea) -> (Velocity, i32) {
    let mut max_height = i32::MIN;
    let mut best_velocity = (0,0);

    for vx in 1..=*target_area.0.end() {
        for vy in *target_area.1.start()..=200 { // nothing very scientific about the end range here
            match fire((vx, vy), &target_area) {
                Some(h) => {
                    if h > max_height {
                        max_height = h;
                        best_velocity = (vx, vy);
                    }
                },
                None => {}
            }
        }
    }
    (best_velocity, max_height)
}

fn find_all_velocities(target_area: &TargetArea) -> Vec<Velocity> {
    let mut velocities = Vec::new();

    for vx in 1..=*target_area.0.end() {
        for vy in *target_area.1.start()..=200 {
            match fire((vx, vy), &target_area) {
                Some(_) => velocities.push((vx, vy)),
                None => {}
            }
        }
    }
    velocities
}

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