import Images: parent

abstract Node{T<:AbstractFloat} <: Intersectable{T}

abstract Tree{T}

type BVH{T<:AbstractFloat}
    tree::Tree{T}
    root
end

aabb(n::Node) = n.bbox
intersect(n::Node, ray::Ray) = intersect(n.bbox, ray)
