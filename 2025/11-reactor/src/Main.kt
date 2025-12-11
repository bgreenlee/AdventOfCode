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

fun countPaths(graph: Map<String, List<String>>, source: String, target: String, required: Set<String>): Long {
    val cache = mutableMapOf<Pair<String, Set<String>>, Long>()

    fun recurse(current: String, found: Set<String>): Long {
        val newFound = if (current in required) found + current else found

        return cache.getOrPut(current to newFound) {
            if (current == target)
                if (newFound == required) 1 else 0
            else
                graph.getValue(current).sumOf { recurse(it, newFound) }
        }
    }

    return recurse(source,emptySet())
}

fun part1(graph: Map<String, List<String>>): Long =
    countPaths(graph,"you", "out", emptySet())

fun part2(graph: Map<String, List<String>>): Long =
    countPaths(graph,"svr", "out", setOf("dac", "fft"))
