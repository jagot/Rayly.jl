abstract type SimpleNode{T,O} <: AbstractNode{T,O} end

struct SimpleTree{T,O} <: AbstractTree{T,O} end
Base.get(::SimpleTree, node::N) where {N<:SimpleNode} = node

nodetype(::SimpleTree{T,O}) where {T,O} = SimpleNode{T,O}

Base.intersect(ray::Ray{T}, n::SimpleNode{T}, tree::SimpleTree{T}) where T =
    intersect(ray, n)

Base.intersect!(intersection::Intersection{T,O}, n::SimpleNode{T,O}, tree::SimpleTree{T,O}) where {T,O} =
    intersect!(intersection, n)

struct BinaryNode{T,O} <: SimpleNode{T,O}
    left::SimpleNode{T,O}
    right::SimpleNode{T,O}

    bbox::AABB{T}
end

function Base.intersect(ray::Ray{T}, n::BinaryNode{T}) where T
    left = intersect(ray, n.left.bbox)
    right = intersect(ray, n.right.bbox)
    (left || right) && (left && intersect(ray, n.left) ||
                      right && intersect(ray, n.right))
end

function Base.intersect!(intersection::Intersection{T,O}, n::BinaryNode{T,O}) where {T,O}
    intersect(intersection.ray, n.bbox) || return
    intersect!(intersection, n.left)
    intersect!(intersection, n.right)
end

add_binary_node!(::SimpleTree{T,O}, left::SimpleNode{T,O}, right::SimpleNode{T,O}) where {T,O} =
    BinaryNode(left, right, AABB(left.bbox, right.bbox))

struct LeafNode{T,O} <: SimpleNode{T,O}
    objs::Vector{O}

    bbox::AABB{T}
end

Base.intersect(ray::Ray{T}, n::LeafNode{T,O}) where {T,O} =
    any(o -> intersect(ray, o), n.objs)

Base.intersect!(intersection::Intersection{T,O}, n::LeafNode{T,O}) where {T,O} =
    foreach(o -> intersect!(intersection, o), n.objs)

add_leaf_node!(::SimpleTree{T,O}, objs::VI, bbox::AABB{T}) where {T,O<:Intersectable{T},VI<:AbstractVector{O}} =
    LeafNode{T,O}(objs[:], bbox)

is_inner(::BinaryNode) = true
is_leaf(::BinaryNode) = false
is_inner(::LeafNode) = false
is_leaf(::LeafNode) = true

objects(n::LeafNode) = n.objs

export SimpleTree
