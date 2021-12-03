import * as fs from 'fs';

function getGammaEpsilon(numbers: number[]): [number, number] {
    // count total number of ones in each bit position
    let bitSize = lines[0].length;
    let counts = new Array<number>(bitSize).fill(0);
    for (let num of numbers) {
        for (let i = 0; i < bitSize; i++) {
            // check if the corresponding bit is set
            let mask = 1 << (bitSize - i - 1);
            if ((num & mask) > 0) {
                counts[i]++;
            }
        }
    }

    let half = numbers.length / 2;
    // most common bits are the counts that are half or more of the total number of lines
    let gamma = counts.reduce((acc, cur, i) => {
        if (cur >= half) {
            acc += Math.pow(2, counts.length - i - 1); // binary -> dec
        }
        return acc;
    }, 0);
    // inverse is 0x1111..1 - gamma
    let eplison = Math.pow(2, counts.length) - 1 - gamma;

    return [gamma, eplison];
}

let input = fs.readFileSync(process.stdin.fd, 'utf-8');
let lines = input.split('\n');
let numbers = lines.map((line) => parseInt(line, 2)); // binary -> dec

let [gamma, epsilon] = getGammaEpsilon(numbers);

console.log(`Part 1: ${gamma * epsilon}`);

let bitSize = lines[0].length;

let o2numbers = numbers;
for (let i = 0; i < bitSize; i++) {
    let [gamma, _] = getGammaEpsilon(o2numbers);
    let mask = 1 << (bitSize - i - 1);
    let target = gamma & mask;
    o2numbers = o2numbers.filter(n => (n & mask) === target);
    if (o2numbers.length === 1) {
        break;
    }
}
let o2generator = o2numbers[0];

let co2numbers = numbers;
for (let i = 0; i < bitSize; i++) {
    let [_, epsilon] = getGammaEpsilon(co2numbers);
    let mask = 1 << (bitSize - i - 1);
    let target = epsilon & mask;
    co2numbers = co2numbers.filter(n => (n & mask) === target);
    if (co2numbers.length === 1) {
        break;
    }
}
let co2scrubber = co2numbers[0];

console.log(`Part 2: ${o2generator * co2scrubber}`);
