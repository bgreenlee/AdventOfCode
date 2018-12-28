#[macro_use] extern crate lazy_static;
use std::io::{self, Read};
use regex::Regex;
use std::collections::{HashMap,HashSet};
use std::env;

#[derive(Debug,Copy,Clone,Eq,PartialEq,Hash)]
enum Attack {
    Bludgeoning,
    Cold,
    Fire,
    Radiation,
    Slashing,
    Unknown,
}

impl Attack {
    fn from_string(input: &str) -> Attack {
        match input {
            "bludgeoning" => Attack::Bludgeoning,
            "cold" => Attack::Cold,
            "fire" => Attack::Fire,
            "radiation" => Attack::Radiation,
            "slashing" => Attack::Slashing,
            _ => Attack::Unknown,
        }
    }
}

#[derive(Debug,Clone,Eq,PartialEq,Hash)]
struct Group {
    id: usize,
    army: ArmyName,
    units: usize,
    hp: usize,
    weaknesses: Vec<Attack>,
    immunities: Vec<Attack>,
    attack_type: Attack,
    attack_damage: usize,
    initiative: usize,
    boost: usize,
}

impl Group {
    fn effective_power(&self) -> usize {
        self.units * (self.attack_damage + self.boost)
    }

    // calculate the amount of damage we'd receive from the attacking group
    fn damage_from_group(&self, attacker: &Group) -> usize {
        if self.weaknesses.contains(&attacker.attack_type) {
            2 * attacker.effective_power()
        } else if self.immunities.contains(&attacker.attack_type) {
            0
        } else {
            attacker.effective_power()
        }
    }

    fn is_alive(&self) -> bool {
        self.units > 0
    }

    // attack other group, returning the number of units killed
    fn attack(&self, other: &mut Group) -> usize {
        let units_killed = other.units.min(other.damage_from_group(self) / other.hp);
        println!("{:?} attacks {:?}, killing {} units", self, other, units_killed);
        other.units -= units_killed;
        units_killed
    }
}

#[derive(Debug,Copy,Clone,Eq,PartialEq,Hash)]
enum ArmyName {
    ImmuneSystem,
    Infection,
    Unknown,
}

impl ArmyName {
    fn from_string(name: &str) -> ArmyName {
        match name {
            "Immune System" => ArmyName::ImmuneSystem,
            "Infection" => ArmyName::Infection,
            _ => ArmyName::Unknown,
        }
    }
}

#[derive(Debug,Clone,Eq,PartialEq)]
struct Army {
    name: ArmyName,
    groups: HashMap<usize, Group>,
}

impl Army {
    fn from_string(name: &str, input: &str) -> Army {
        lazy_static! {
            // 17 units each with 5390 hit points (weak to radiation, bludgeoning) with an attack that does 4507 fire damage at initiative 2
            static ref GROUP_RE: Regex = Regex::new(r"(?P<units>\d+) units each with (?P<hp>\d+) hit points\s*(?P<weak_immune>\(.*?\))?\s*with an attack that does (?P<attack_damage>\d+) (?P<attack_type>\w+) damage at initiative (?P<initiative>\d+)").unwrap();
            static ref WEAK_IMMUNE_RE: Regex = Regex::new(r"(weak|immune) to (.*?)(?:;|\))").unwrap();
        }
        let army = ArmyName::from_string(name);
        let mut groups = HashMap::new();
        for (id, line) in input.lines().enumerate() {
            if let Some(caps) = GROUP_RE.captures(line) {
                let units = caps.name("units").unwrap().as_str().parse::<usize>().unwrap();
                let hp = caps.name("hp").unwrap().as_str().parse::<usize>().unwrap();
                let mut weaknesses = Vec::new();
                let mut immunities = Vec::new();
                if let Some(weak_immune) = caps.name("weak_immune") {
                    for wi_cap in WEAK_IMMUNE_RE.captures_iter(weak_immune.as_str()) {
                        let attacks = wi_cap.get(2).unwrap().as_str().split(", ").map(|a| Attack::from_string(a)).collect::<Vec<_>>();
                        match wi_cap.get(1).unwrap().as_str() {
                            "weak" => weaknesses.extend(attacks),
                            "immune" => immunities.extend(attacks),
                            _ => (),
                        }
                    }
                }
                let attack_damage = caps.name("attack_damage").unwrap().as_str().parse::<usize>().unwrap();
                let attack_type = Attack::from_string(caps.name("attack_type").unwrap().as_str());
                let initiative = caps.name("initiative").unwrap().as_str().parse::<usize>().unwrap();
                groups.insert(id + 1 , Group { id: id + 1, army, units, hp, weaknesses, immunities, attack_type, attack_damage, initiative, boost: 0 });
            }
        }
        Army { name: army, groups }
    }

    fn live_groups(&self) -> Vec<Group> {
        self.groups.values()
            .filter(|&g| g.is_alive())
            .map(|g| g.clone())
            .collect::<Vec<_>>()
    }

    fn boost(&mut self, amount: usize) {
        self.groups.values_mut().for_each(|g| g.boost = amount);
    }
}

#[derive(Debug)]
struct Battle {
    round: usize,
    immune_system: Army,
    infection: Army,
}

impl Battle {
    fn from_string(input: &str) -> Battle {
        lazy_static! {
            static ref ARMY_RE: Regex = Regex::new(r"(?sm)^(?P<name>[\w\s]+):\n(?P<groups>.*?)(?:\n\n|\z)").unwrap();
        }

        let armies : Vec<Army> = ARMY_RE.captures_iter(input)
            .map(|cap| {
                Army::from_string(cap.name("name").unwrap().as_str(), cap.name("groups").unwrap().as_str())
            })
            .collect::<Vec<_>>();
        Battle { round: 0, immune_system: armies[0].clone(), infection: armies[1].clone() }
    }

    // return a hashmap of attacking group => defending group
    fn select_targets(&self, attacker: &Army, defender: &Army) -> HashMap<usize,usize> {
        let mut attack_map = HashMap::new();
        // each group attempts to choose one target
        // groups go in decreasing order of effective power, initiative
        let mut attackers = attacker.live_groups();
        let mut defenders = defender.live_groups();

        // attackers go in decreasing order of effective power, initiative
        attackers.sort_by(|a,b|
            if b.effective_power() == a.effective_power() {
                b.initiative.cmp(&a.initiative)
            } else {
                b.effective_power().cmp(&a.effective_power())
            }
        );

        // keep track of who's been targeted already
        let mut targeted = HashSet::new();
        for attacking_group in &attackers {
            // target is chosen in decreasing order of damage, effective power, and initiative
            defenders.sort_by(|a,b| {
                let b_damage = b.damage_from_group(&attacking_group);
                let a_damage = a.damage_from_group(&attacking_group);
                if b_damage == a_damage {
                    if b.effective_power() == a.effective_power() {
                        b.initiative.cmp(&a.initiative)
                    } else {
                        b.effective_power().cmp(&a.effective_power())
                    }
                } else {
                    b_damage.cmp(&a_damage)
                }});

            for target in &defenders {
                if !targeted.contains(target) && target.is_alive() && target.damage_from_group(&attacking_group) > 0 {
                    attack_map.insert(attacking_group.id, target.id);
                    targeted.insert(target.clone());
                    break;
                }
            }
        }

        attack_map
    }

    fn advance(&mut self) {
        self.round += 1;
//        println!("Round {}:", self.round);

        let immune_attack_map = self.select_targets(&self.immune_system, &self.infection);
        let infection_attack_map = self.select_targets(&self.infection, &self.immune_system);

        // attack phase
        // get all groups, sorted by initiative
        let mut groups : Vec<Group> = Vec::new();
        groups.append(&mut self.immune_system.live_groups());
        groups.append(&mut self.infection.live_groups());
        groups.sort_by(|a,b| b.initiative.cmp(&a.initiative) );

        for attacker in groups {
            // reload the attacker each time
            match attacker.army {
                ArmyName::ImmuneSystem => {
                    let attacker = self.immune_system.groups.get(&attacker.id).unwrap();
                    if let Some(defender_id) = &immune_attack_map.get(&attacker.id) {
                        let defender = self.infection.groups.get_mut(&defender_id).unwrap();
                        attacker.attack(defender);
                    }
                }
                ArmyName::Infection => {
                    let attacker = self.infection.groups.get(&attacker.id).unwrap();
                    if let Some(defender_id) = &infection_attack_map.get(&attacker.id) {
                        let defender = self.immune_system.groups.get_mut(&defender_id).unwrap();
                        attacker.attack(defender);
                    }
                },
                _ => (),
            };
        }
    }
}
/*
Immune System:
17 units each with 5390 hit points (weak to radiation, bludgeoning) with an attack that does 4507 fire damage at initiative 2
989 units each with 1274 hit points (immune to fire; weak to bludgeoning, slashing) with an attack that does 25 slashing damage at initiative 3

Infection:
801 units each with 4706 hit points (weak to radiation) with an attack that does 116 bludgeoning damage at initiative 1
4485 units each with 2961 hit points (immune to radiation; weak to fire, cold) with an attack that does 12 slashing damage at initiative 4
*/

fn main() {
    let mut boost = 0;
    if env::args().len() > 1 {
        boost = env::args().nth(1).unwrap_or("0".to_string()).parse::<usize>().unwrap();
    }
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer).expect("Error reading from stdin");
    let mut battle = Battle::from_string(&buffer);
    battle.immune_system.boost(boost);
    //println!("{:?}", battle);
    while battle.immune_system.live_groups().len() > 0 && battle.infection.live_groups().len() > 0 {
        battle.advance();
    }

    println!("Immune System:");
    if battle.immune_system.live_groups().len() > 0 {
        let mut total_units = 0;
        for group in battle.immune_system.live_groups() {
            println!("Group {} contains {} units", group.id, group.units);
            total_units += group.units;
        }
        println!("Total units left: {}", total_units);
    } else {
        println!("No groups remain.");
    }
    println!("Infection:");
    if battle.infection.live_groups().len() > 0 {
        let mut total_units = 0;
        for group in battle.infection.live_groups() {
            println!("Group {} contains {} units", group.id, group.units);
            total_units += group.units;
        }
        println!("Total units left: {}", total_units);
    } else {
        println!("No groups remain.");
    }
}
