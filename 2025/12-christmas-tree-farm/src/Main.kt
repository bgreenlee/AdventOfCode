import java.io.File

fun main() {
    val input = File("data/input.dat").readLines()
    // parse shapes
    val shapes = (0..5).map { i ->
        input.slice(i * 5 + 1..i * 5 + 3)
            .sumOf { it.toCharArray().count { it == '#' } }
    }
    // parse regions
    val regions = (30 until input.size).map { i ->
        val (areaStr, quantitiesStr) = input[i].split(":")
        val area = areaStr.split("x")
            .map { it.toInt() }
            .reduce { acc, n -> acc * n }
        val quantities = quantitiesStr.trim().split(" ").map { it.toInt() }
        area to quantities
    }

    println("part 1: " + part1(shapes, regions))
}

// lazy solution — just look at total area, ignore rotation
fun part1(shapes: List<Int>, regions: List<Pair<Int,List<Int>>>): Int =
    regions.count { (area, quantities) ->
        val totalShapesArea = (0 until quantities.size).sumOf { i -> quantities[i] * shapes[i] }
        area >= totalShapesArea
    }
