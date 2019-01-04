mutable struct Intersection{T<:AbstractFloat}
    o::Union{Intersectable{T},Nothing}
    ray::Ray{T}
    t::T
    u::T
    v::T
end

# Intersection(o::Intersectable{T}, ray::Ray{T}, t::T) where T =
#     Intersection{T}(o, ray, t, zero(T), zero(T))
Intersection(ray::Ray{T}) where T =
    Intersection{T}(nothing, ray, convert(T, Inf), zero(T), zero(T))

function normal(i::Intersection)
    p = i.ray.pos + i.t*i.ray.dir
    normal(i.o, p, i)
end

Base.isless(a::Intersection, b::Intersection) = (a.t < b.t)

is_hit(a::Intersection) = a.o != nothing

export Intersection, normal
