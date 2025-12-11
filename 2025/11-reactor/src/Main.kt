import java.io.File

fun main() {
    val input = File("data/input.dat").readLines()
    val graph = input.associate { line ->
        val parts = line.split(Regex("[:\\s]+"))
        parts.first() to parts.drop(1)
    }

    println("part 1: " + part1(graph))
    println("part 2: " + part2(graph))
}


fun part1(graph: Map<String, List<String>>): Long {
    val cache = mutableMapOf<String, Long>()
    fun countPaths(source: String, target: String): Long =
        cache.getOrPut(source) {
            if (source == target) 1
            else graph.getValue(source)
                .sumOf { countPaths(it, target) }
        }

    return countPaths("you", "out")
}

fun part2(graph: Map<String, List<String>>): Long {
    val cache = mutableMapOf<Triple<String, Boolean, Boolean>,Long>()
    fun countPaths(source: String, target: String, foundDac: Boolean, foundFft: Boolean): Long =
        cache.getOrPut(Triple(source, foundDac, foundFft)) {
            if (source == target) {
                if (foundDac && foundFft) 1 else 0
            } else {
                graph.getValue(source)
                    .sumOf {
                        countPaths(it, target,
                            foundDac || source == "dac",
                            foundFft || source == "fft"
                        )
                    }
            }
        }

    return countPaths("svr", "out", false, false)
}