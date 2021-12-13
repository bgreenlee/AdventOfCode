use std::collections::{HashMap, HashSet};
use std::io::{self, Read};

struct Map {
    map: HashMap<String, Node>,
}

impl Map {
    fn new(lines: Vec<&str>) -> Map {
        let mut map = HashMap::new();
        for line in lines {
            let nodes: Vec<&str> = line.split("-").collect();
            let (from, to) = (nodes[0], nodes[1]);

            let from_node = map.entry(from.to_string()).or_insert(Node::new(from));
            from_node.connections.insert(String::from(to));
            let to_node = map.entry(to.to_string()).or_insert(Node::new(to));
            to_node.connections.insert(String::from(from));
        }
        Map { map }
    }

    fn paths(&mut self, start: &str, end: &str, extra_visit: bool) -> Vec<Vec<String>> {
        let mut current_path: Vec<String> = Vec::new();
        let mut simple_paths: Vec<Vec<String>> = Vec::new();

        Self::depth_first_search(self, start, end,
            &mut current_path, &mut simple_paths, extra_visit);

        simple_paths
    }

    fn depth_first_search(map: &Map, from: &str, to: &str,
        current_path: &mut Vec<String>, simple_paths: &mut Vec<Vec<String>>, extra_visit: bool)
    {
        let node = map.map.get(from).unwrap();
        if node.is_small() && current_path.contains(&from.to_string()) {
            if !extra_visit || node.is_start() || node.is_end() {
                return
            }
        
            // a whole lotta work to see if we've already had our extra visit
            let mut visit_counts: HashMap<String, u8> = HashMap::new();
            let small_caves = current_path.into_iter()
                .filter(|n| n.chars().nth(0).unwrap() >= 'a')
                .map(|n| n.to_string())
                .collect::<Vec<String>>();
            for small_cave in small_caves {
                *visit_counts.entry(small_cave).or_default() += 1;
            }
            if visit_counts.values().max().unwrap_or(&0) > &1 {
                return;
            }
        }

        current_path.push(from.to_string());

        if from == to {
            simple_paths.push(current_path.clone());
            current_path.pop();
            return;
        }

        for connection in &node.connections {
            Self::depth_first_search(map, connection, to,
                current_path, simple_paths, extra_visit);
        }

        current_path.pop();
    }
}

struct Node {
    name: String,
    connections: HashSet<String>,
}

impl Node {
    fn new(name: &str) -> Node {
        Node {
            name: String::from(name),
            connections: HashSet::new(),
        }
    }

    fn is_small(&self) -> bool {
        self.name.chars().nth(0).unwrap() >= 'a'
    }

    fn is_start(&self) -> bool {
        self.name == "start"
    }

    fn is_end(&self) -> bool {
        self.name == "end"
    }
}

fn main() {
    let mut buffer = String::new();
    io::stdin()
        .read_to_string(&mut buffer)
        .expect("Error reading from stdin");
    let lines: Vec<&str> = buffer.lines().collect();

    let mut map = Map::new(lines);
    let part1_paths = map.paths("start", "end", false);
    println!("{}", part1_paths.len());

    let part2_paths = map.paths("start", "end", true);
    println!("{}", part2_paths.len());
}
