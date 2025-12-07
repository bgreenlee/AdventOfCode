import java.io.File

fun main() {
    val input = File("data/input.dat").readLines()

    val (part1, part2) = solve(input)
    println("part 1: $part1")
    println("part 2: $part2")
}

fun solve(input: List<String>): Pair<Int, Long> {
    val beams = mutableMapOf<Int, Long>(input.first().indexOf('S') to 1)
    var splitCount = 0
    for (line in input)
        for ((x, char) in line.withIndex())
            if (char == '^' && x in beams) {
                val parentCount = beams.getValue(x)
                if (x > 0) beams.merge(x - 1, parentCount, Long::plus)
                if (x < line.length) beams.merge(x + 1, parentCount, Long::plus)
                beams.remove(x)
                splitCount++
            }

    return splitCount to beams.values.sum()
}
