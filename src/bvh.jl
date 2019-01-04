abstract type AbstractNode{T<:AbstractFloat} <: Intersectable{T} end
abstract type AbstractTree{T<:AbstractFloat} end

mutable struct BVH{T,Tree<:AbstractTree{T},N<:AbstractNode{T}}
    tree::Tree
    root::N
end

aabb(n::N) where {N<:AbstractNode} = n.bbox
Base.intersect(ray::Ray{T}, n::N) where {T,N<:AbstractNode{T}} = intersect(ray, n.bbox)
