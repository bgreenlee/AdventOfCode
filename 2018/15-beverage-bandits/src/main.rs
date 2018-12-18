extern crate indoc;

use std::cmp::Ordering;
use std::io::{self, Read};
use std::collections::{BinaryHeap, HashMap, HashSet};
use std::{usize,fmt};
use std::sync::atomic::{self, AtomicUsize};
use std::env;

#[derive(PartialEq,Eq,Hash,Copy,Clone)]
struct Location {
    x: usize,
    y: usize,
}

impl fmt::Debug for Location {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "({},{})", self.x, self.y)
    }
}

impl Ord for Location {
    fn cmp(&self, other: &Location) -> Ordering {
        if self.y == other.y {
            self.x.cmp(&other.x)
        } else {
            self.y.cmp(&other.y)
        }
    }
}

impl PartialOrd for Location {
    fn partial_cmp(&self, other: &Location) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

#[derive(Debug,PartialEq,Eq,Hash,Copy,Clone)]
enum Race { Elf, Goblin }

static PLAYER_ID : AtomicUsize = atomic::ATOMIC_USIZE_INIT;
#[derive(PartialEq,Eq,Hash,Copy,Clone)]
struct Player {
    id: usize,
    race: Race,
    hp: i32,
    location: Location,
    attack_power: i32,
}

impl Player {
    fn new(race: Race, location: Location, attack_power: i32) -> Player {
        Player { id: PLAYER_ID.fetch_add(1, std::sync::atomic::Ordering::SeqCst), race, hp: 200, location, attack_power }
    }

    fn is_alive(&self) -> bool {
        self.hp > 0
    }

    fn is_adjacent(&self, player: &Player) -> bool {
        let sl = self.location;
        let pl = player.location;
        sl != pl && (
            (sl.x == pl.x && (sl.y as i32 - pl.y as i32).abs() == 1) ||
            (sl.y == pl.y && (sl.x as i32 - pl.x as i32).abs() == 1)
        )
    }
}

impl fmt::Debug for Player {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{:?} #{} @ {:?} (hp: {})", self.race, self.id, self.location, self.hp)
    }
}

impl Ord for Player {
    fn cmp(&self, other: &Player) -> Ordering {
        self.location.cmp(&other.location)
    }
}

impl PartialOrd for Player {
    fn partial_cmp(&self, other: &Player) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

// for Dijkstra
#[derive(Copy, Clone, Eq, PartialEq)]
struct State {
    location: Location,
    distance: usize,
}

// Define ordering for a min-heap (lowest distance will come out first)
impl Ord for State {
    fn cmp(&self, other: &State) -> Ordering {
        // in case of a tie, order by location
        other.distance.cmp(&self.distance)
            .then_with(|| other.location.cmp(&self.location))
    }
}

impl PartialOrd for State {
    fn partial_cmp(&self, other: &State) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

struct Game {
    round: usize,
    tiles: HashSet<Location>,
    players: Vec<Player>,
    width: usize,
    height: usize,
}

impl fmt::Debug for Game {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let mut output = String::new();
        output.push_str(&format!("After {} rounds:\n", self.round));
        let player_locations = self.player_locations();
        for y in 0..self.height {
            let mut players = Vec::new();
            for x in 0..self.width {
                let location = Location { x, y };
                if self.tiles.contains(&location) {
                    match player_locations.get(&location) {
                        Some(player) if player.is_alive() => {
                            match player.race {
                                Race::Elf => output.push('E'),
                                Race::Goblin => output.push('G'),
                            };
                            players.push(player);
                        },
                        _ => {
                            output.push('.');
                        },
                    }
                } else {
                    output.push('#');
                }
            }
            output.push_str("  ");
            let mut player_strs = Vec::new();
            for player in players {
                let mut player_str = String::new();
                match player.race {
                    Race::Elf => player_str.push('E'),
                    Race::Goblin => player_str.push('G'),
                };
                player_str.push_str(&format!("({})", player.hp));
                player_strs.push(player_str);
            }
            output.push_str(&player_strs.join(", "));
            output.push('\n');
        }
        write!(f, "{}", output)
    }
}

impl Game {
    fn from_string(input: &str, elf_attack_power: i32) -> Game {
        let mut tiles = HashSet::new();
        let mut players = Vec::new();

        let lines : Vec<_> = input.lines().collect();
        for (y,line) in lines.iter().enumerate() {
            for (x,c) in line.chars().enumerate() {
                let location = Location { x, y };
                match c {
                    '.' => {
                        tiles.insert(location);
                    },
                    'E' => {
                        tiles.insert(location);
                        players.push(Player::new(Race::Elf, location, elf_attack_power));
                    },
                    'G' => {
                        tiles.insert(location);
                        players.push(Player::new(Race::Goblin, location, 3));
                    },
                    _ => (),
                }
            }
        }
        Game { round: 0, tiles, players, width: lines[0].len(), height: lines.len() }
    }

    // return live players after sorting in order of location
    fn live_players(&self) -> Vec<Player> {
        let mut players = self.players.clone();
        players.sort();
        players.into_iter()
            .filter(|p| p.is_alive())
            .collect()
    }

    // return HashMap of location -> player
    fn player_locations(&self) -> HashMap<Location, Player> {
        let mut player_locations = HashMap::new();
        for player in self.live_players() {
            player_locations.insert(player.location,player);
        }
        player_locations
    }

    // return just the elves
    fn elves(&self) -> Vec<Player> {
        let live_players = self.live_players();
        live_players.into_iter()
            .filter(|p| p.race == Race::Elf)
            .collect()
    }

    // return just the globins
    fn goblins(&self) -> Vec<Player> {
        let live_players = self.live_players();
        live_players.into_iter()
            .filter(|p| p.race == Race::Goblin)
            .collect()
    }

    fn enemies(&self, player: &Player) -> Vec<Player> {
        match player.race {
            Race::Elf => self.goblins(),
            Race::Goblin => self.elves(),
        }
    }

    // return a list of open tiles adjacent to the given tile
    fn open_neighbors(&self, location: &Location) -> Vec<Location> {
        let mut open_neighbors = Vec::new();
        let player_locations = self.player_locations();
        let (x, y) = (location.x, location.y);
        let neighbors : Vec<Location> = vec![
            Location { x, y: y - 1 }, Location { x: x - 1, y },
            Location { x: x + 1, y }, Location { x, y: y + 1 }
        ];
        for neighbor in neighbors {
            if self.tiles.contains(&neighbor) && !player_locations.contains_key(&neighbor) {
                open_neighbors.push(neighbor);
            }
        }
        open_neighbors
    }

    // Dijkstra's shortest path algorithm
    // cribbed from the Rust docs for binary_heap and https://rosettacode.org/wiki/Dijkstra%27s_algorithm#Rust
    fn shortest_path(&mut self, start: Location, goal: Location) -> Option<Vec<Location>> {
        // dist[location] = (current shortest distance from `start` to `location`, prev node)
        let mut dist : HashMap<Location, (usize, Option<Location>)> = self.tiles.iter()
            .map(|loc| (*loc, (usize::MAX, None)))
            .collect::<HashMap<_, _>>();

        let mut heap = BinaryHeap::new();

        dist.insert(start, (0, None));
        heap.push(State { location: start, distance: 0 });

        // Examine the frontier with lower-cost nodes first (min-heap)
        while let Some(State { location, distance }) = heap.pop() {
            if location == goal {
                //println!("{:?}", dist);
                // walk back and build path
                let mut path = Vec::with_capacity(dist.len() / 2);
                let mut current_dist = &dist[&goal];
                path.push(goal);
                while let Some(prev) = current_dist.1 {
                    path.push(prev);
                    current_dist = &dist[&prev];
                }
                path.reverse();
                return Some(path);
            }

            if distance > dist[&location].0 {
                continue;
            }
            // for each node we can reach, see if we can find a way with a lower cost going
            // through this node
            for neighbor in self.open_neighbors(&location) {
                let next = State { distance: distance + 1, location: neighbor };
                if next.distance < dist[&next.location].0 {
                    // found a better way
                    heap.push(next);
                    dist.insert(next.location,(next.distance, Some(location)));
                }
            }
        }
//        println!("...no path from {:?} to {:?}", start, goal);
        None // not reachable
    }

    fn advance(&mut self) -> Result<(),&'static str> {
        'outer: for player in self.live_players() {
            let mut player = self.players[player.id]; // reload to make sure
            if !player.is_alive() {
                continue;
            }
            // get list of live enemies
            let enemies = self.enemies(&player);
            if enemies.is_empty() {
                return Err("game over");
            }
            let adjacent_enemies = enemies.iter()
                .filter(|e| e.is_adjacent(&player))
                .collect::<Vec<&Player>>();

            if adjacent_enemies.is_empty() {
                // otherwise, find the shortest path to an open space next to the closest enemy,
                let open_spaces = enemies.iter()
                    .map(|e| self.open_neighbors(&e.location))
                    .flatten()
                    .collect::<Vec<Location>>();
                let mut paths = open_spaces.iter()
                    .map(|target| self.shortest_path(player.location, *target))
                    .filter(|path| path.is_some())
                    .map(|path| path.unwrap())
                    .collect::<Vec<Vec<Location>>>();
                if !paths.is_empty() {
                    paths.sort_by(|a,b|
                        if a[a.len()-1] == b[b.len()-1] {
                            // if the paths are to the same target, sort by first step
                            a[1].cmp(&b[1])
                        } else if a.len() == b.len() {
                            // paths are to different targets, but same length, so sort by target
                            a[a.len()-1].cmp(&b[b.len()-1])
                        } else {
                            // order by path length
                            a.len().cmp(&b.len())
                        });

                    // and take one step in that direction
//                    println!("{:?} moving to {:?} (target: {:?})", player, paths[0][1], paths[0].last().unwrap());
                    self.players[player.id].location = paths[0][1]; // paths[0][0] should be the player's own location
                }
            }

            // look for adjacent enemies again
            player = self.players[player.id]; // refresh player
            let enemies = self.enemies(&player);
            let mut adjacent_enemies = enemies.iter()
                .filter(|e| e.is_adjacent(&player))
                .collect::<Vec<&Player>>();
            // if any enemies are adjacent, attack the one with the least hp
            if !adjacent_enemies.is_empty() {
                adjacent_enemies.sort_by(|a,b|
                    if a.hp == b.hp {
                        a.location.cmp(&b.location)
                    } else {
                        a.hp.cmp(&b.hp)
                    });
//                println!("{:?} attacking {:?}", player, adjacent_enemies[0]);
                self.players[adjacent_enemies[0].id].hp -= player.attack_power;
            }
        }
        self.round += 1;
        Ok(())
    }
}

fn main() {
    let mut elf_attack_power = 3;
    if env::args().len() > 1 {
        elf_attack_power = env::args().nth(1).unwrap_or("3".to_string()).parse::<i32>().expect("could not parse input!");
    }
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer).expect("Error reading from stdin");
    let mut game = Game::from_string(&buffer, elf_attack_power);

//    println!("Initially:\n{:?}", game);

    while game.advance().is_ok() {
//        println!("{:?}", game);
    }

//    println!("{:#?}", game.elves());
//    println!("{:#?}", game.goblins());

    let elves_total_hp = game.elves().iter().map(|p| p.hp).sum::<i32>();
    let goblins_total_hp = game.goblins().iter().map(|p| p.hp).sum::<i32>();
    let (winner, winner_hp) = if elves_total_hp > 0 { ("Elves", elves_total_hp) }
        else { ("Goblins", goblins_total_hp) };

    println!("Combat ends after {} full rounds", game.round);
    println!("{} win with {} total hit points left", winner, winner_hp);
    println!("Outcome: {} * {} = {}", game.round, winner_hp, game.round as i32 * winner_hp);

    let elves_died = game.players.iter()
        .filter(|p| p.race == Race::Elf && !p.is_alive())
        .map(|p| *p)
        .collect::<Vec<Player>>()
        .len();

    println!("{} elves died", elves_died);
}

#[cfg(test)]
mod tests {
    use super::*;
    use indoc::indoc;

    #[test]
    fn test_open_neighbors() {
        let map = indoc!("
            #######
            #..G..#
            #....G#
            #.#G#G#
            #...#E#
            #.....#
            #######
        ");
        let game = Game::from_string(map, 3);
        assert_eq!(game.open_neighbors(&Location { x: 5, y: 2}),
                   vec![Location { x: 5, y: 1 },
                        Location { x: 4, y: 2 }]);
        assert_eq!(game.open_neighbors(&Location { x: 2, y: 2}),
                   vec![Location { x: 2, y: 1 },
                        Location { x: 1, y: 2 },
                        Location { x: 3, y: 2 }]);
        assert_eq!(game.open_neighbors(&Location { x: 5, y: 4}),
                   vec![Location { x: 5, y: 5 }]);
    }

    #[test]
    fn test_shortest_path() {
        let map = indoc!("
            #######
            #..G..#
            #....G#
            #.#G#G#
            #...#E#
            #.....#
            #######
        ");
        let mut game = Game::from_string(map, 3);
        assert_eq!(game.shortest_path(Location { x: 5, y: 2},Location { x: 5, y: 5}),
            Some(vec![
                 Location { x: 5, y: 2 }, Location { x: 4, y: 2 }, Location { x: 3, y: 2 },
                 Location { x: 2, y: 2 }, Location { x: 1, y: 2 }, Location { x: 1, y: 3 },
                 Location { x: 1, y: 4 }, Location { x: 2, y: 4 }, Location { x: 3, y: 4 },
                 Location { x: 3, y: 5 }, Location { x: 4, y: 5 }, Location { x: 5, y: 5 },
            ]));
        assert_eq!(game.shortest_path(Location { x: 5, y: 3},Location { x: 5, y: 5}), None);
        assert_eq!(game.shortest_path(Location { x: 3, y: 1},Location { x: 4, y: 2}),
                   Some(vec![
                       Location { x: 3, y: 1}, Location { x: 4, y: 1 }, Location { x: 4, y: 2 },
                   ]));

    }

//    #[test]
//    fn test_advance() {
//        let map = indoc!("
//            #######
//            #..G..#
//            #....G#
//            #.#G#G#
//            #...#E#
//            #.....#
//            #######
//        ");
//        let mut game = Game::from_string(map);
//        game.advance();
//        let player_locations = game.player_locations();
//        assert_eq!(game.player_locations().contains_key(&Location{ x: 5, y: 2 }), false);
//        assert_eq!(game.player_locations().contains_key(&Location{ x: 4, y: 2 }), true);
//        assert_eq!(game.player_locations().contains_key(&Location{ x: 5, y: 1 }), false);
//    }
}