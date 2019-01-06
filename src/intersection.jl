mutable struct Intersection{T<:AbstractFloat,O<:Intersectable{T}}
    o::Union{O,Nothing}
    ray::Ray{T}
    t::T
    u::T
    v::T
end

Intersection(ray::Ray{T},::Type{O}) where {T,O} =
    Intersection{T,O}(nothing, ray, convert(T, Inf), zero(T), zero(T))

function normal(i::Intersection)
    p = i.ray.pos + i.t*i.ray.dir
    normal(i.o, p, i)
end

Base.isless(a::Intersection, b::Intersection) = (a.t < b.t)

is_hit(a::Intersection) = a.o != nothing

export Intersection, normal
