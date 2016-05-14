import Base: get
import Images: parent

abstract Node{T<:AbstractFloat} <: Intersectable{T}

# This type keeps track of parents/siblings using integer indices
abstract IntNode{T<:AbstractFloat} <: Node{T}

abstract Tree{T}

type IntTree{T<:AbstractFloat} <: Tree{T}
    nodes::Vector{IntNode{T}}
    IntTree() = new(Vector{IntNode{T}}())
end
get(tree::IntTree, node::Int) = tree.nodes[node]

type BVH{T<:AbstractFloat}
    tree::Tree{T}
    root
end

aabb(n::Node) = n.bbox
parent(n::Node, t::IntTree) = t.nodes[n.parent]
sibling(n::Node, t::IntTree) = t.nodes[n.sibling]
intersect(n::Node, ray::Ray) = intersect(n.bbox, ray)

type BinaryIntNode{T<:AbstractFloat} <: IntNode{T}
    left::Int
    right::Int
    parent::Int
    sibling::Int
    
    bbox::AABB{T}
end

function intersect{T<:AbstractFloat}(n::BinaryIntNode{T}, tree::IntTree{T}, ray::Ray{T})
    left = intersect(tree.nodes[n.left].bbox, ray)
    right = intersect(tree.nodes[n.right].bbox, ray)
    if left || right
        intersect(tree.nodes[n.left], tree, ray) ||
            intersect(tree.nodes[n.right], tree, ray)
    else
        false
    end
end

function add_binary_node!{T<:AbstractFloat}(tree::IntTree{T}, left::Int, right::Int)
    lnode = tree.nodes[left]
    rnode = tree.nodes[right]
    bbox = AABB(aabb(lnode), aabb(rnode))
    node = BinaryIntNode(left, right, 0, 0, bbox)
    push!(tree.nodes, node)
    lnode.sibling = right
    rnode.sibling = left
    lnode.parent = rnode.parent = length(tree.nodes)
end

type LeafIntNode{T<:AbstractFloat} <: IntNode{T}
    objs::Vector{Intersectable{T}}
    parent::Int
    sibling::Int
    
    bbox::AABB{T}
end

function intersect{T<:AbstractFloat}(n::LeafIntNode{T}, tree::IntTree{T}, ray::Ray{T})
    for i in eachindex(n.objs)
        intersect(n.objs[i], ray) && return true
    end
    false
end

function add_leaf_node!{T<:AbstractFloat}(tree::IntTree{T},
                                          objs::AbstractVector{Intersectable{T}},
                                          bbox::AABB{T})
    node = LeafIntNode(objs[:], 0, 0, bbox)
    push!(tree.nodes, node)
    length(tree.nodes)
end

# Necessary?
add_leaf_node!(tree::Tree, objs::Vector{Intersectable}) =
    add_leaf_node!(tree, objs, bbox, AABB(objs))

is_inner(::BinaryIntNode) = true
is_leaf(::BinaryIntNode) = false
is_inner(::LeafIntNode) = false
is_leaf(::LeafIntNode) = true
