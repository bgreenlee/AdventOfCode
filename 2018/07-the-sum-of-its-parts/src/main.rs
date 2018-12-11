use std::io::{self, Read};
use std::collections::{BTreeMap, HashMap, HashSet};

fn main() {
    let num_workers = 5;
    let base_delay = 60;

    let mut work_queue : HashMap<char, u8> = HashMap::new();
    let mut completed : Vec<char> = Vec::new();
    let mut dependencies : BTreeMap<char, HashSet<char>> = BTreeMap::new();

    // read in the input
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer).expect("Error reading from stdin");
    // parse the input lines into tuples
    let input : Vec<(char,char)> = buffer.lines()

        .map(|l| {
            let mut words = l.split_whitespace();
            let first = words.nth(1).unwrap_or("-");
            let second = words.nth(5).unwrap_or("-");
            (first.chars().nth(0).unwrap_or('-'),
             second.chars().nth(0).unwrap_or('-'))
        }).collect();

    // populate the dependencies graph
    for (a, b) in input {
        dependencies.entry(a).or_insert(HashSet::new());
        let mut deps = dependencies.entry(b).or_insert(HashSet::new());
        deps.insert(a);
    }

//    println!("dependencies: {:?}", dependencies);

    let mut clock = 0;
    let total_steps = dependencies.keys().len();
    while completed.len() < total_steps {
//        println!("clock: {}", clock);

        // anything without dependencies we can move to the work queue
        for (step, deps) in dependencies.iter().by_ref() {
            if deps.is_empty() && !work_queue.contains_key(step) && work_queue.keys().len() < num_workers {
                work_queue.insert(*step, base_delay + *step as u8 - 65);
            }
        }

//        println!("work queue: {:?}", work_queue);

        // update work queue, move anything that has timed out to completed
        for (step, time_remaining) in &work_queue {
            if *time_remaining == 0 && !completed.contains(step) {
                completed.push(*step);
                dependencies.remove(step);
            }
        }

//        println!("completed: {:?}", completed);

        // remove all completed from the dependencies
        for (_, mut deps) in dependencies.iter_mut() {
            if !deps.is_empty() {
                for c in completed.iter().by_ref() {
                    deps.remove(&c);
                }
            }
        }

//        println!("updated deps: {:?}", dependencies);

        // remove zero-ed steps and decrement
        work_queue = work_queue.iter()
            .filter(|(_k,v)| **v > 0)
            .map(|(k,v)| (*k, *v - 1))
            .collect();

//        println!("updated work queue: {:?}", work_queue);

        clock += 1;

//        // wait for enter
//        let mut input = String::new();
//        io::stdin().read_line(&mut input);
    }

    let answer : String = completed.iter().collect();
    println!("answer: {}", answer);
    println!("time: {}", clock);
}
