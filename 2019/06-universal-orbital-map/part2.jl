#!/usr/bin/env julia

mutable struct Node
    name
    parent::Union{Node, Nothing}
    children::Array{Node}
end

orphan(n) = Node(n, nothing, [])

function addchild!(n::Node, c::Node)
    c.parent = n
    push!(n.children, c)
end

# recursively generate a list of all subnodes (children, children's children, etc.)
function subnodes(n::Node)
    a = copy(n.children)
    for c in n.children
        append!(a, subnodes(c))
    end
    a
end

# ancestors are all nodes above, up to the root
function ancestors(n::Node)
    a = []
    while n.parent != nothing
        push!(a, n.parent)
        n = n.parent
    end
    a
end

# find the first common ancestor between two nodes
common_ancestor(a::Node, b::Node) = first(intersect(ancestors(a), ancestors(b)))

# the distance between two nodes is the sum of the distances to the common ancestor
distance(a::Node, b::Node) = length(ancestors(a)) + length(ancestors(b)) - 2 * (length(ancestors(common_ancestor(a, b))) + 1)

function generate_tree(map)
    all_nodes = Dict()
    for line in map
        parent, child = split(chomp(line), ")")
        child_node = get(all_nodes, child, orphan(child))
        parent_node = get(all_nodes, parent, orphan(parent))
        addchild!(parent_node, child_node)
        all_nodes[parent] = parent_node
        all_nodes[child] = child_node
    end
    all_nodes
end

map = readlines(ARGS[1])
tree = generate_tree(map)
println(distance(tree["YOU"], tree["SAN"]))
