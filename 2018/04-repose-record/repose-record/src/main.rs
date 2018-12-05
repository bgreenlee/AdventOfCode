extern crate chrono;
use std::io::{self, Read};
use std::collections::HashMap;
use chrono::*;

#[derive(Debug)]
enum GuardAction {
    BeginShift,
    FallAsleep,
    WakeUp,
    Undefined,
}

#[derive(Debug)]
struct GuardRecord {
    timestamp : DateTime<Utc>,
    id : i32,
    action: GuardAction,
}

impl GuardRecord {
    fn new(record_str : &str) -> GuardRecord {
        let parts : Vec<&str> = record_str
            .split(|c:char| !c.is_alphanumeric())
            .filter(|c| !c.is_empty())
            .collect();

        let year = parts[0].parse::<i32>().unwrap_or(0);
        let month = parts[1].parse::<u32>().unwrap_or(0);
        let day = parts[2].parse::<u32>().unwrap_or(0);
        let hour = parts[3].parse::<u32>().unwrap_or(0);
        let min = parts[4].parse::<u32>().unwrap_or(0);
        let timestamp = Utc.ymd(year, month, day).and_hms(hour, min, 0);

        let id = match parts[5] {
            "Guard" => parts[6].parse::<i32>().unwrap_or(0),
            _ => -1,
        };
        let action = match parts[5] {
            "Guard" => GuardAction::BeginShift,
            "falls" => GuardAction::FallAsleep,
            "wakes" => GuardAction::WakeUp,
            _ => GuardAction::Undefined,
        };
        GuardRecord { timestamp, id, action }
    }
}

fn main() -> io::Result<()> {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer)?;
    let mut records : Vec<&str> = buffer.lines().collect();
    records.sort();

    let mut guard_sleep = HashMap::new();
    let mut current_guard_id = -1;
    let mut last_sleep_start = 0;
    for record_str in records.iter() {
        let mut record = GuardRecord::new(record_str);
        if record.id == -1 {
            record.id = current_guard_id;
        }
        match record.action {
            GuardAction::BeginShift => current_guard_id = record.id,
            GuardAction::FallAsleep => last_sleep_start = record.timestamp.time().minute(),
            GuardAction::WakeUp => {
                let mut sleep_record = guard_sleep.entry(record.id).or_insert([0; 60]);
                let last_sleep_end = record.timestamp.time().minute();
                for i in last_sleep_start..last_sleep_end {
                    sleep_record[i as usize] += 1;
                }
            }
            _ => (),
        }
    }

    let mut max_sleep = 0;
    let mut max_sleep_id = -1;
    let mut total_sleepiest_minute = 0;
    let mut total_sleepiest_minute_amount = 0;
    let mut total_sleepiest_minute_id = -1;
    for (id, sleep_record) in guard_sleep.iter() {
        let sleep = sleep_record.iter().sum();
        if sleep > max_sleep {
            max_sleep = sleep;
            max_sleep_id = id.to_owned();
        }
        let most_sleep = sleep_record.iter().max().unwrap().to_owned();
        if most_sleep > total_sleepiest_minute_amount {
            total_sleepiest_minute_amount = most_sleep;
            total_sleepiest_minute_id = id.to_owned();
            total_sleepiest_minute = sleep_record.iter().position(|&s| s == most_sleep).unwrap();
        }

    }
    println!("Sleepiest guard: {}", max_sleep_id);
    max_sleep = *guard_sleep.get(&max_sleep_id).unwrap().iter().max().unwrap();
    let sleepiest_minute = guard_sleep.get(&max_sleep_id).unwrap().iter().position(|&s| s == max_sleep).unwrap();
    println!("Sleepiest minute: {}", sleepiest_minute);

    println!("Total sleepiest minute: {}", total_sleepiest_minute);
    println!("Total sleepiest minute id: {}", total_sleepiest_minute_id);
    Ok(())
}
