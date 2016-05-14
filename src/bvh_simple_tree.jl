import Base: get
abstract SimpleNode{T<:AbstractFloat} <: Node{T}

type SimpleTree{T<:AbstractFloat} <: Tree{T}
end
get(tree::Tree, node::Node) = node

intersect{T<:AbstractFloat}(n::SimpleNode{T},
                            tree::Tree{T},
                            ray::Ray{T}) = intersect(n, ray)

type BinaryNode{T<:AbstractFloat} <: SimpleNode{T}
    left::SimpleNode{T}
    right::SimpleNode{T}

    bbox::AABB{T}
end

function intersect{T<:AbstractFloat}(n::BinaryNode{T},
                                     ray::Ray{T})
    left = intersect(n.left.bbox, ray)
    left = intersect(n.left.bbox, ray)
    if left || right
        intersect(n.left, ray) || intersect(n.right, ray)
    else
        false
    end
end

function add_binary_node!{T<:AbstractFloat}(tree::Tree{T},
                                            left::SimpleNode{T},
                                            right::SimpleNode{T})
    bbox = AABB(left.bbox, right.bbox)
    BinaryNode(left, right, bbox)
end

type LeafNode{T<:AbstractFloat} <: SimpleNode{T}
    objs::Vector{Intersectable{T}}

    bbox::AABB{T}
end

function intersect{T<:AbstractFloat}(n::LeafNode{T},
                                     ray::Ray{T})
    for i in eachindex(n.objs)
        intersect(n.objs[i], ray) && return true
    end
    false
end

function add_leaf_node!{T<:AbstractFloat}(tree::Tree{T},
                                          objs::AbstractVector{Intersectable{T}},
                                          bbox::AABB{T})
    LeafNode(objs[:], bbox)
end
