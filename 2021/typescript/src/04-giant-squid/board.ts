type Coord = [number, number];

class Cell {
    value: number;
    coord: Coord;
    marked: boolean;

    constructor(value: number, coord: Coord, marked: boolean = false) {
        this.value = value;
        this.coord = coord;
        this.marked = marked;
    }
}

export class Board {
    private size: number; // assumes square board
    private numberMap = new Map<number, Cell>();
    // You can't use a non-primitive type as a key in a Map in JS because it uses === when it fetches and that will never be true for an object or array
    private coordMap = new Map<string, Cell>();
    private lastMarked?: number;

    constructor(rows: string[]) {
        this.size = rows.length;
        for (let y = 0; y < rows.length; y++) {
            let numbers = rows[y].trim().split(/\s+/).map(n => +n);
            for (let x = 0; x < numbers.length; x++) {
                let num = numbers[x];
                let coord: Coord = [x, y];
                let cell = new Cell(num, coord);
                this.numberMap.set(num, cell);
                this.coordMap.set(coord.toString(), cell);
            }
        }
    }

    clear() {
        let cells = this.numberMap.values();
        for (let cell of cells) {
            cell.marked = false;
        }
    }

    mark(num: number) {
        let cell = this.numberMap.get(num);
        if (cell) {
            cell.marked = true;
            this.lastMarked = num;
        }
    }

    isRowMarked(row: number): boolean {
        for (let x = 0; x < this.size; x++) {
            if (!this.coordMap.get([x, row].toString())?.marked) {
                return false;
            }
        }
        return true;
    }

    isColumnMarked(col: number): boolean {
        for (let y = 0; y < this.size; y++) {
            if (!this.coordMap.get([col, y].toString())?.marked) {
                return false;
            }
        }
        return true;
    }

    isWinner(): boolean {
        for (let i = 0; i < this.size; i++) {
            if (this.isRowMarked(i) || this.isColumnMarked(i)) {
                return true;
            }
        }
        return false;
    }

    score(): number {
        let cells = Array.from(this.numberMap.values());
        let unmarkedSum = cells.filter(cell => !cell.marked).reduce((acc, cell) => acc + cell.value, 0);
        return unmarkedSum * (this.lastMarked || 0);
    }

    toString(): string {
        let output = "";
        for (let y = 0; y < this.size; y++) {
            for (let x = 0; x < this.size; x++) {
                let cellStr = "     ";
                let cell = this.coordMap.get([x, y].toString());
                if (cell) {
                    cellStr = (cellStr + (cell.marked ? `(${cell.value})` : `${cell.value}`)).slice(-5);
                }
                output += cellStr;
            }
            output += "\n";
        }
        return output;
    }
}