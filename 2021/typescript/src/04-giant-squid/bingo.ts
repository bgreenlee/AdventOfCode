import { Board } from './board';
import { log } from './log';

export class Bingo {
    private numbers: number[];
    private boards: Board[] = [];

    constructor(input: string) {
        let lines = input.split('\n');
        this.numbers = lines.shift()?.split(',').map(n => +n) || [];
        // collect the boards
        let boardLines: string[] = [];
        for (let line of lines) {
            line = line.trim()
            if (line === "") {
                if (boardLines.length > 0) {
                    this.boards.push(new Board(boardLines));
                    boardLines = [];
                }
            } else {
                boardLines.push(line);
            }
        }
        if (boardLines.length > 0) {
            this.boards.push(new Board(boardLines));
        }
    }

    clear() {
        this.boards.forEach(b => b.clear());
    }

    getFirstWinner(): Board | undefined {
        this.clear();
        for (let num of this.numbers) {
            log(`Mark: ${num}`);

            for (let board of this.boards) {
                board.mark(num);

                log(board.toString() + "\n");

                if (board.isWinner()) {
                    return board;
                }
            }
        }
    }

    getAllWinners(): Board[] {
        this.clear();
        let winners: Board[] = [];
        for (let num of this.numbers) {
            let remainingBoards = this.boards.filter(b => !b.isWinner())
            for (let board of remainingBoards) {
                board.mark(num);
                if (board.isWinner()) {
                    winners.push(board);
                }
            }
        }
        return winners;
    }
}