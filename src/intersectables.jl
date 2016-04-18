using FixedSizeArrays

abstract Intersectable

type Intersection
    o::Intersectable
    ray::Ray
    t
    u
    v
end

Intersection(o, ray, t) = Intersection(o, ray, t, 0, 0)
function normal(i::Intersection)
    p = i.ray.pos + i.t*i.ray.dir
    normal(i.o, p, i)
end

import Base.<, Base.isless
<(a::Intersection, b::Intersection) = (a.t < b.t)
isless(a::Intersection, b::Intersection) = (a < b)

export Intersectable, Sphere, Intersection, normal
