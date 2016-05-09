type Intersection{T<:AbstractFloat}
    o::Nullable{Intersectable{T}}
    ray::Ray{T}
    t::T
    u::T
    v::T
end

Intersection{T}(o::Intersectable{T}, ray::Ray{T}, t::T) = Intersection(Nullable{Intersectable{T}}(o), ray, t, zero(T), zero(T))
Intersection{T}(ray::Ray{T}) = Intersection(Nullable{Intersectable{T}}(), ray, convert(T, Inf), zero(T), zero(T))

function normal(i::Intersection)
    p = i.ray.pos + i.t*i.ray.dir
    normal(get(i.o), p, i)
end

import Base.<, Base.isless
<(a::Intersection, b::Intersection) = (a.t < b.t)
isless(a::Intersection, b::Intersection) = (a < b)

export Intersection, normal
