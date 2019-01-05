# This type keeps track of parents/siblings using integer indices
abstract type IntNode{T,O} <: AbstractNode{T,O} end

struct IntTree{T,O,UI<:Unsigned} <: AbstractTree{T,O}
    nodes::Vector{IntNode{T,O}}
end
IntTree{T,O,UI}() where {T,O,UI} = IntTree{T,O,UI}(Vector{IntNode{T,O}}())
IntTree(::Type{T},::Type{O},::Type{UI}=UInt) where {T,O,UI} = IntTree{T,O,UI}()
IntTree{T,O}() where {T,O} = IntTree(T,O)

Base.getindex(tree::IntTree, node::Int) = tree.nodes[node]

nodetype(::IntTree{T,O}) where {T,O} = IntNode{T,O}

parent(n::IntNode, t::IntTree) = t.nodes[n.parent]
sibling(n::IntNode, t::IntTree) = t.nodes[n.sibling]

mutable struct BinaryIntNode{T,O} <: IntNode{T,O}
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

function Base.intersect!(intersection::Intersection{T,O}, n::BinaryIntNode{T,O}, tree::IntTree{T,O}) where {T,O}
    intersect(intersection.ray, n.bbox) || return
    intersect!(intersection, tree.nodes[n.left], tree)
    intersect!(intersection, tree.nodes[n.right], tree)
end

function add_binary_node!(tree::IntTree{T,O}, left::Int, right::Int) where {T,O}
    lnode = tree.nodes[left]
    rnode = tree.nodes[right]
    bbox = AABB(aabb(lnode), aabb(rnode))
    node = BinaryIntNode{T,O}(left, right, 0, 0, bbox)
    push!(tree.nodes, node)
    lnode.sibling = right
    rnode.sibling = left
    lnode.parent = rnode.parent = length(tree.nodes)
end

mutable struct LeafIntNode{T,O} <: IntNode{T,O}
    objs::Vector{O}
    parent::Int
    sibling::Int

    bbox::AABB{T}
end

Base.intersect(ray::Ray{T}, n::LeafIntNode{T,O}, tree::IntTree{T,O}) where {T,O} =
    any(o -> intersect(ray, o), n.objs)

function Base.intersect!(intersection::Intersection{T,O}, n::LeafIntNode{T,O}) where {T,O}
    foreach(o -> intersect!(intersection, o), n.objs)
    is_hit(intersection)
end
Base.intersect!(intersection::Intersection{T,O}, n::LeafIntNode{T,O}, ::IntTree{T,O}) where {T,O} =
    intersect!(intersection, n)

function add_leaf_node!(tree::IntTree{T,O},
                        objs::AbstractVector{O},
                        bbox::AABB{T}) where {T,O<:Intersectable{T}}
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
