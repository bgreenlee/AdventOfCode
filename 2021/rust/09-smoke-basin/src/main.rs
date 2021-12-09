use std::io::{self, Read};

fn main() {
    let mut buffer = String::new();
    io::stdin()
        .read_to_string(&mut buffer)
        .expect("Error reading from stdin");
    let lines: Vec<&str> = buffer.lines().collect();

    // populate map
    let height = lines.len();
    let width = lines[0].len();
    let mut map: Vec<Vec<u32>> = vec![vec![0; width]; height];
    for y in 0..height {
        for (x, c) in lines[y].char_indices() {
            map[y][x] = c.to_digit(10).unwrap();
        }
    }

    // Part 1: Find low points
    let mut low_points: Vec<(usize, usize)> = Vec::new();
    let mut sum = 0;
    for y in 0..height {
        for x in 0..width {
            let curr = map[y][x];
            if (y > 0 && map[y - 1][x] <= curr)
                || (x + 1 < width && map[y][x + 1] <= curr)
                || (y + 1 < height && map[y + 1][x] <= curr)
                || (x > 0 && map[y][x - 1] <= curr)
            {
                continue;
            }
            low_points.push((x, y));
            sum += curr + 1;
        }
    }
    println!("Part 1: {}", sum);

    // Part 2: Find basins
    let mut visited: Vec<Vec<bool>> = vec![vec![false; width]; height];
    let mut basin_sizes: Vec<u32> = low_points
        .into_iter()
        .map(|point| {
            let mut size: u32 = 0;
            flood_fill(&mut map, &mut visited, point, &mut size);
            return size;
        })
        .collect();
    basin_sizes.sort_by(|a, b| b.cmp(a));

    let score = basin_sizes[0] * basin_sizes[1] * basin_sizes[2];
    println!("Part 2: {}", score);
}

fn flood_fill(
    map: &mut Vec<Vec<u32>>,
    visited: &mut Vec<Vec<bool>>,
    point: (usize, usize),
    size: &mut u32,
) {
    let (x, y) = point;
    if visited[y][x] || map[y][x] == 9 {
        return;
    }
    *size += 1;
    visited[y][x] = true;

    let height = map.len();
    let width = map[0].len();
    if y > 0 {
        flood_fill(map, visited, (x, y - 1), size);
    }
    if x + 1 < width {
        flood_fill(map, visited, (x + 1, y), size);
    }
    if y + 1 < height {
        flood_fill(map, visited, (x, y + 1), size);
    }
    if x > 0 {
        flood_fill(map, visited, (x - 1, y), size);
    }
}
