import java.io.File

fun main() {
    val input = File("data/input.dat").readLines()

    val (part1, part2) = solve(input)
    println("part 1: $part1")
    println("part 2: $part2")
}

fun solve(input: List<String>): Pair<Int, Long> {
    val beams = mutableMapOf<Int, Long>(input.first().length / 2 to 1)
    var splitCount = 0
    for (line in input) {
        for ((x, char) in line.withIndex()) {
            if (char == '^' && beams.contains(x)) {
                if (x > 0) beams[x - 1] = (beams[x - 1] ?: 0) + (beams[x] ?: 0)
                if (x < line.length) beams[x + 1] = (beams[x + 1] ?: 0) + (beams[x] ?: 0)
                beams.remove(x)
                splitCount += 1
            }
        }
    }
    return Pair(splitCount, beams.values.sum())
}
