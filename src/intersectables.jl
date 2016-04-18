using FixedSizeArrays

abstract Intersectable{T}

import Base.eltype
eltype{T}(::Intersectable{T}) = T

type Intersection{T<:AbstractFloat}
    o::Intersectable{T}
    ray::Ray{T}
    t::T
    u::T
    v::T
end

Intersection{T}(o, ray, t::T) = Intersection(o, ray, t, zero(T), zero(t))
function normal(i::Intersection)
    p = i.ray.pos + i.t*i.ray.dir
    normal(i.o, p, i)
end

import Base.<, Base.isless
<(a::Intersection, b::Intersection) = (a.t < b.t)
isless(a::Intersection, b::Intersection) = (a < b)

export Intersectable, Intersection, normal
