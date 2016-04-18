using FixedSizeArrays

abstract Intersectable

type Intersection
    o::Intersectable
    ray::Ray
    t
end

import Base.<, Base.isless
<(a::Intersection, b::Intersection) = (a.t < b.t)
isless(a::Intersection, b::Intersection) = (a < b)

export Intersectable, Sphere, Intersection
