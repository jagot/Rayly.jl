mutable struct ListAccelerator{T,O} <: Accelerator{T,O}
    objs::Vector{O}
end
ListAccelerator(objs::Vector{O}) where {T,O<:Intersectable{T}} =
    ListAccelerator{T,O}(objs)

ListAccelerator(::Type{O}) where {T,O<:Intersectable{T}} =
    ListAccelerator(Vector{O}())

Base.intersect(ray::Ray{T}, acc::ListAccelerator{T}) where T =
    any(o -> intersect(ray,o), acc.objs)

Base.intersect!(intersection::Intersection{T}, acc::ListAccelerator{T}) where T =
    foreach(o -> intersect!(intersection, o), acc.objs)

export ListAccelerator
