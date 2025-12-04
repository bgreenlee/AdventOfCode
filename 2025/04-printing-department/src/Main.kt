import java.io.File

fun main() {
    val input = File("data/input.dat").readLines()
    println("part 1: " + part1(input))
    println("part 2: " + part2(input))
}

typealias Point = Pair<Int, Int>

class PaperMap {
    var height: Int = 0
    var width: Int = 0
    var rolls: MutableSet<Point> = mutableSetOf()

    constructor(input: List<String>) {
        this.height = input.count()
        this.width = input[0].length

        for ((y, row) in input.withIndex())
            for ((x, char) in row.withIndex())
                if (char == '@') this.rolls.add(Point(x, y))
    }

    // return list of neighbors of the given roll
    fun neighborList(point: Point): List<Point> {
        val neighbors: MutableList<Point> = mutableListOf()
        for (dy in -1..1) {
            for (dx in -1..1) {
                if (dx == 0 && dy == 0) continue
                val neighbor = Point(point.first + dx, point.second + dy)
                if (this.rolls.contains(neighbor)) neighbors.add(neighbor)
            }
        }
        return neighbors
    }

    // return rolls that are accessible (have fewer than 4 neighbors)
    fun accessibleRolls(): List<Point> {
        return this.rolls.filter { neighborList(it).count() < 4 }
    }

    // remove accessible rolls, returning the number of rolls removed
    fun removeAccessibleRolls(): Int {
        val rolls = this.accessibleRolls()
        this.rolls.removeAll(rolls)
        return rolls.count()
    }
}

fun part1(input: List<String>): Int {
    return PaperMap(input).accessibleRolls().count()
}

fun part2(input: List<String>): Int {
    val paperMap = PaperMap(input)
    var sum = 0
    do {
        val removed = paperMap.removeAccessibleRolls()
        sum += removed
    } while (removed > 0)

    return sum
}
