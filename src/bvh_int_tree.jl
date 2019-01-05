# This type keeps track of parents/siblings using integer indices
abstract type IntNode{T} <: AbstractNode{T} end

struct IntTree{T} <: AbstractTree{T}
    nodes::Vector{IntNode{T}}
end
IntTree{T}() where T = IntTree{T}(Vector{IntNode{T}}())
IntTree(::Type{T}) where T = IntTree{T}()

Base.get(tree::IntTree, node::Int) = tree.nodes[node]

nodetype(::IntTree{T}) where T = IntNode{T}

parent(n::IntNode, t::IntTree) = t.nodes[n.parent]
sibling(n::IntNode, t::IntTree) = t.nodes[n.sibling]

mutable struct BinaryIntNode{T} <: IntNode{T}
    left::Int
    right::Int
    parent::Int
    sibling::Int

    bbox::AABB{T}
end

function Base.intersect(ray::Ray{T}, n::BinaryIntNode{T}, tree::IntTree{T}) where T
    left = intersect(ray, tree.nodes[n.left].bbox)
    right = intersect(ray, tree.nodes[n.right].bbox)
    (left || right) && (left && intersect(ray, tree.nodes[n.left], tree) ||
                      right && intersect(ray, tree.nodes[n.right], tree))
end

function Base.intersect!(intersection::Intersection{T}, n::BinaryIntNode{T}, tree::IntTree{T}) where T
    intersect(intersection.ray, n.bbox) || return
    intersect!(intersection, tree.nodes[n.left], tree)
    intersect!(intersection, tree.nodes[n.right], tree)
end

function add_binary_node!(tree::IntTree{T}, left::Int, right::Int) where T
    lnode = tree.nodes[left]
    rnode = tree.nodes[right]
    bbox = AABB(aabb(lnode), aabb(rnode))
    node = BinaryIntNode(left, right, 0, 0, bbox)
    push!(tree.nodes, node)
    lnode.sibling = right
    rnode.sibling = left
    lnode.parent = rnode.parent = length(tree.nodes)
end

mutable struct LeafIntNode{T} <: IntNode{T}
    objs::Vector{Intersectable{T}}
    parent::Int
    sibling::Int

    bbox::AABB{T}
end

Base.intersect(ray::Ray{T}, n::LeafIntNode{T}, tree::IntTree{T}) where T =
    any(o -> intersect(ray, o), n.objs)

function Base.intersect!(intersection::Intersection{T}, n::LeafIntNode{T}) where T
    foreach(o -> intersect!(intersection, o), n.objs)
    is_hit(intersection)
end
Base.intersect!(intersection::Intersection{T}, n::LeafIntNode{T}, ::IntTree{T}) where T =
    intersect!(intersection, n)

function add_leaf_node!(tree::IntTree{T},
                        objs::AbstractVector{Intersectable{T}},
                        bbox::AABB{T}) where T
    node = LeafIntNode(objs[:], 0, 0, bbox)
    push!(tree.nodes, node)
    length(tree.nodes)
end

is_inner(::BinaryIntNode) = true
is_leaf(::BinaryIntNode) = false
is_inner(::LeafIntNode) = false
is_leaf(::LeafIntNode) = true

objects(n::LeafIntNode) = n.objs

export IntTree
