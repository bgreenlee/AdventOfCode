import java.io.File
import kotlin.math.sqrt
import kotlin.math.pow

data class Point(val x: Int, val y: Int, val z: Int) {
    fun dist(other: Point): Float = sqrt(
        (x - other.x).toFloat().pow(2) +
                (y - other.y).toFloat().pow(2) +
                (z - other.z).toFloat().pow(2)
    )

    override fun toString(): String = "$x,$y,$z"
}

data class PointPair(val a: Point, val b: Point) {
    val dist: Float = a.dist(b)
}

fun main() {
    val input = File("data/input.dat").readLines()
    val points = input.map {
        val (x, y, z) = it.split(",").map(String::toInt)
        Point(x, y, z)
    }

    println("part 1: " + solve(points, 1000))
    println("part 2: " + solve(points))
}

fun solve(points: List<Point>, numToMerge: Int = -1): Long {
    val pairs = mutableListOf<PointPair>()
    for (i in 0 until points.size - 1)
        for (j in i+1 until points.size) {
            pairs.add(PointPair(points[i], points[j]))
        }

    val closest = pairs.sortedBy { it.dist }.take(if (numToMerge < 0) pairs.size else numToMerge)
    val seedCircuit = mutableSetOf(closest.first().a, closest.first().b)
    val circuits = mutableListOf(seedCircuit)

    for (pair in closest.drop(1)) {
        var foundCircuit = false
        for ((i, circuit) in circuits.withIndex()) {
            if (pair.a in circuit || pair.b in circuit) {
                circuit.add(pair.a)
                circuit.add(pair.b)
                // if a or b is part of another circuit, we need to combine circuits
                for (j in i+1 until circuits.size) {
                    if (pair.a in circuits[j] || pair.b in circuits[j]) {
                        circuit.addAll(circuits[j])
                        circuits[j] = mutableSetOf<Point>()
                    }
                }

                // if we're merging all, stop when it's one big circuit
                if (numToMerge < 0 && circuit.size == points.size) {
                    return pair.a.x.toLong() * pair.b.x
                }

                foundCircuit = true
                break
            }
        }
        if (!foundCircuit) circuits.add(mutableSetOf(pair.a, pair.b))
    }

    return circuits.sortedBy { -it.size }
        .take(3)
        .map { it.size.toLong() }
        .reduce { acc, x -> acc * x }
}
