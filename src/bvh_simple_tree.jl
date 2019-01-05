abstract type SimpleNode{T} <: AbstractNode{T} end

struct SimpleTree{T} <: AbstractTree{T} end
Base.get(::SimpleTree, node::N) where {N<:AbstractNode} = node

nodetype(::SimpleTree{T}) where T = SimpleNode{T}

Base.intersect(ray::Ray{T}, n::SimpleNode{T}, tree::SimpleTree{T}) where T =
    intersect(ray, n)

Base.intersect!(intersection::Intersection{T}, n::SimpleNode{T}, tree::SimpleTree{T}) where T =
    intersect!(intersection, n)

struct BinaryNode{T} <: SimpleNode{T}
    left::SimpleNode{T}
    right::SimpleNode{T}

    bbox::AABB{T}
end

function Base.intersect(ray::Ray{T}, n::BinaryNode{T}) where T
    left = intersect(ray, n.left.bbox)
    right = intersect(ray, n.right.bbox)
    (left || right) && (left && intersect(ray, n.left) ||
                      right && intersect(ray, n.right))
end

function Base.intersect!(intersection::Intersection{T}, n::BinaryNode{T}) where T
    intersect(intersection.ray, n.bbox) || return
    intersect!(intersection, n.left)
    intersect!(intersection, n.right)
end

add_binary_node!(::SimpleTree{T}, left::SimpleNode{T}, right::SimpleNode{T}) where T =
    BinaryNode(left, right, AABB(left.bbox, right.bbox))

struct LeafNode{T} <: SimpleNode{T}
    objs::Vector{Intersectable{T}}

    bbox::AABB{T}
end

Base.intersect(ray::Ray{T}, n::LeafNode{T}) where T =
    any(o -> intersect(ray, o), n.objs)

Base.intersect!(intersection::Intersection{T}, n::LeafNode{T}) where T =
    foreach(o -> intersect!(intersection, o), n.objs)

add_leaf_node!(::SimpleTree{T}, objs::VI, bbox::AABB{T}) where {T,VI<:AbstractVector{Intersectable{T}}} =
    LeafNode(objs[:], bbox)

is_inner(::BinaryNode) = true
is_leaf(::BinaryNode) = false
is_inner(::LeafNode) = false
is_leaf(::LeafNode) = true

export SimpleTree
