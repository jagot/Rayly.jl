mutable struct ListAccelerator{T} <: Accelerator{T}
    objs::Vector{Intersectable{T}}
end
ListAccelerator(::Type{T}) where T = ListAccelerator(Vector{Intersectable{T}}())

Base.intersect(ray::Ray{T}, acc::ListAccelerator{T}) where T =
    any(o -> intersect(ray,o), acc.objs)

Base.intersect!(intersection::Intersection{T}, acc::ListAccelerator{T}) where T =
    foreach(o -> intersect!(intersection, o), acc.objs)

export ListAccelerator
