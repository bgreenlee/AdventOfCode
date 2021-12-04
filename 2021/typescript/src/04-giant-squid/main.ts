import * as fs from 'fs';
import { Bingo } from './bingo';

let input = fs.readFileSync(process.stdin.fd, 'utf-8');
// let input = fs.readFileSync('/Users/brad/Code/AdventOfCode/2021/typescript/src/04-giant-squid/test.dat', 'utf-8');

let bingo = new Bingo(input);

let firstWinner = bingo.getFirstWinner();
console.log(`Part 1: ${firstWinner?.score()}`);

let allWinners = bingo.getAllWinners();
if (allWinners) {
    console.log(`Part 2: ${allWinners[allWinners.length -1].score()}`);
}
