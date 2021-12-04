import { Board } from './board';

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
        for (let board of this.boards) {
            board.clear();
        }
    }

    getFirstWinner(): Board | undefined {
        this.clear();
        for (let num of this.numbers) {
            for (let board of this.boards) {
                board.mark(num);

                if (board.isWinner()) {
                    return board;
                }
            }
        }
    }

    getAllWinners(): Board[] {
        this.clear();
        let boards: Board[] = [];
        for (let num of this.numbers) {
            for (let board of this.boards) {
                if (!board.isWinner()) {
                    board.mark(num);
                    if (board.isWinner()) {
                        boards.push(board);
                    }
                }
            }
        }
        return boards;
    }
}