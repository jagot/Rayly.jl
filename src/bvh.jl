abstract Node{T<:AbstractFloat} <: Intersectable{T}

# This type keeps track of parents/siblings using integer indices
abstract IntNode{T<:AbstractFloat} <: Node{T}

abstract Tree{T}
import Base: get

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

