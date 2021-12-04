type Cell = {
    value: number;
    marked: boolean;
}

export class Board {
    private size: number; // assumes square board
    private cells: Cell[][] = [];
    private lastMarked?: number;
    private winner = false;

    constructor(rows: string[]) {
        this.size = rows.length;
        for (let row of rows) {
            let numbers = row.trim().split(/\s+/).map(n => +n);
            let cellRow = numbers.map(n => <Cell>{value: n, marked: false});
            this.cells.push(cellRow);
        }
    }

    clear() {
        this.cells.flat().forEach(cell => cell.marked = false);
    }

    mark(num: number) {
        let cell = this.cells.flat().find(cell => cell.value == num);
        if (cell) {
            cell.marked = true;
            this.lastMarked = num;
        }
    }

    isRowMarked(row: number): boolean {
        return this.cells[row].every(cell => cell.marked);
    }

    isColumnMarked(col: number): boolean {
        return this.cells.map(row => row[col]).every(cell => cell.marked);
    }

    isWinner(): boolean {
        // once a winner, always a winner
        if (this.winner) { 
            return true;
        }

        for (let i = 0; i < this.size; i++) {
            if (this.isRowMarked(i) || this.isColumnMarked(i)) {
                this.winner = true;
                return true;
            }
        }
        return false;
    }

    score(): number {
        let unmarkedCells = this.cells.flat().filter(cell => !cell.marked);
        let sum = unmarkedCells.reduce((acc, cell) => acc + cell.value, 0);
        return sum * (this.lastMarked || 0);
    }

    toString(): string {
        return this.cells.map(row => {
            return row.map(cell => ("     " + (cell.marked ? `(${cell.value})` : `${cell.value}`)).slice(-5))
                      .join("")
        }).join("\n");
    }
}