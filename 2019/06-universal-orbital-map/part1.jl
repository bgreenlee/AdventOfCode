#!/usr/bin/env julia

struct Node
    name
    children::Array{Node}
end

leaf(n) = Node(n, [])
addchild!(n::Node, c::Node) = push!(n.children, c)

function subnodes(n::Node)
    a = copy(n.children)
    for c in n.children
        append!(a, subnodes(c))
    end
    a
end

function generate_tree(map)
    all_nodes = Dict()
    for line in map
        parent, child = split(chomp(line), ")")
        child_node = get(all_nodes, child, leaf(child))
        parent_node = get(all_nodes, parent, leaf(parent))
        addchild!(parent_node, child_node)
        all_nodes[parent] = parent_node
        all_nodes[child] = child_node
    end
    all_nodes
end

map = readlines(ARGS[1])
tree = generate_tree(map)
all_nodes = subnodes(tree["COM"])
total = length(all_nodes) + sum(n -> length(subnodes(n)), all_nodes)
println(total)