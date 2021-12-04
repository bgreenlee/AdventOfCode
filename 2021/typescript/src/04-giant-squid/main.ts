import * as fs from 'fs';
import { Bingo } from './bingo';

let input = fs.readFileSync(process.stdin.fd, 'utf-8');

let bingo = new Bingo(input);

let firstWinner = bingo.getFirstWinner();
console.log(`Part 1: ${firstWinner?.score()}`);

let allWinners = bingo.getAllWinners();
if (allWinners) {
    console.log(`Part 2: ${allWinners[allWinners.length -1].score()}`);
}
